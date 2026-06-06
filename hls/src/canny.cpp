#include "canny.hpp"
#include <cmath>

#define M_PI 3.14159265358979323846

// Using pointers to flat 1D arrays for hardware synthesis (Maps to AXI Master in HLS)
void canny_fpga_naive(
    const unsigned char* src, unsigned char* dst, 
    float* x_buf, float* y_buf, float* mag_buf, float* nms_buf,
    int rows, int cols, float low_thresh, float high_thresh) 
{
    // AXI4-Lite Interfaces for control and scalar arguments
    #pragma HLS INTERFACE s_axilite port=return bundle=CTRL
    #pragma HLS INTERFACE s_axilite port=rows bundle=CTRL
    #pragma HLS INTERFACE s_axilite port=cols bundle=CTRL
    #pragma HLS INTERFACE s_axilite port=low_thresh bundle=CTRL
    #pragma HLS INTERFACE s_axilite port=high_thresh bundle=CTRL

    // AXI4-Master Interfaces for array pointers (All sharing the main DDR memory)
    #pragma HLS INTERFACE m_axi port=src offset=slave bundle=gmem
    #pragma HLS INTERFACE m_axi port=dst offset=slave bundle=gmem
    #pragma HLS INTERFACE m_axi port=x_buf offset=slave bundle=gmem
    #pragma HLS INTERFACE m_axi port=y_buf offset=slave bundle=gmem
    #pragma HLS INTERFACE m_axi port=mag_buf offset=slave bundle=gmem
    #pragma HLS INTERFACE m_axi port=nms_buf offset=slave bundle=gmem

    const int cent = 2; // Fixed to 5x5 mask for hardware static array bounding
    const float sig = 1.0f;
    float maskx[5][5], masky[5][5];
    
    // 1. Generate Gaussian 1st Derivative Masks 
    // (Vivado HLS will unroll this and create a static hardware ROM at compile time)
    for (int p = -cent; p <= cent; p++) {
        #pragma HLS loop_tripcount min=128 max=1024 avg=512
        for (int q = -cent; q <= cent; q++) {
            #pragma HLS loop_tripcount min=128 max=1024 avg=512
            maskx[p+cent][q+cent] = q * std::exp(-1.0f * ((p * p + q * q) / (2.0f * sig * sig)));
            masky[p+cent][q+cent] = p * std::exp(-1.0f * ((p * p + q * q) / (2.0f * sig * sig)));
        }
    }

    float max_mag = 0.0f;

    // 2. Convolution: Blur + Gradient in a single step
    // Safe boundary to prevent reading outside the image
    for (int r = cent; r < rows - cent; r++) {
        #pragma HLS loop_tripcount min=128 max=1024 avg=512
        for (int c = cent; c < cols - cent; c++) {
            #pragma HLS loop_tripcount min=128 max=1024 avg=512
            float sumx = 0.0f, sumy = 0.0f;
            for (int p = -cent; p <= cent; p++) {
                #pragma HLS loop_tripcount min=128 max=1024 avg=512
                for (int q = -cent; q <= cent; q++) {
                    #pragma HLS loop_tripcount min=128 max=1024 avg=512
                    float pixel = src[(r + p) * cols + (c + q)];
                    sumx += pixel * maskx[p + cent][q + cent];
                    sumy += pixel * masky[p + cent][q + cent];
                }
            }
            x_buf[r * cols + c] = sumx;
            y_buf[r * cols + c] = sumy;

            float mag = std::sqrt(sumx * sumx + sumy * sumy);
            mag_buf[r * cols + c] = mag;
            
            // Track max magnitude for normalization
            if (mag > max_mag) {
                max_mag = mag;
            }
        }
    }

    // Normalize Magnitude to 0-255
    for (int r = cent; r < rows - cent; r++) {
        #pragma HLS loop_tripcount min=128 max=1024 avg=512
        for (int c = cent; c < cols - cent; c++) {
            #pragma HLS loop_tripcount min=128 max=1024 avg=512
            mag_buf[r * cols + c] = (mag_buf[r * cols + c] / max_mag) * 255.0f;
        }
    }

    // 3. Peak Detection (Non-Maximum Suppression)
    for (int r = cent + 1; r < rows - cent - 1; r++) {
        #pragma HLS loop_tripcount min=128 max=1024 avg=512
        for (int c = cent + 1; c < cols - cent - 1; c++) {
            #pragma HLS loop_tripcount min=128 max=1024 avg=512
            float vx = x_buf[r * cols + c];
            if (vx == 0.0f) vx = 0.0001f; // Avoid division by zero
            float slope = y_buf[r * cols + c] / vx;

            float mag = mag_buf[r * cols + c];
            float q = 255.0f, prev = 255.0f;

            // Pre-calculate tangent angles in radians
            float tan22_5 = std::tan(22.5 * M_PI / 180.0);
            float tan67_5 = std::tan(67.5 * M_PI / 180.0);

            if (slope <= tan22_5 && slope > -tan22_5) {
                q = mag_buf[r * cols + (c - 1)];
                prev = mag_buf[r * cols + (c + 1)];
            }
            else if (slope <= tan67_5 && slope > tan22_5) {
                q = mag_buf[(r - 1) * cols + (c - 1)];
                prev = mag_buf[(r + 1) * cols + (c + 1)];
            }
            else if (slope <= -tan22_5 && slope > -tan67_5) {
                q = mag_buf[(r + 1) * cols + (c - 1)];
                prev = mag_buf[(r - 1) * cols + (c + 1)];
            }
            else {
                q = mag_buf[(r - 1) * cols + c];
                prev = mag_buf[(r + 1) * cols + c];
            }

            if (mag > q && mag > prev) {
                nms_buf[r * cols + c] = mag;
            } else {
                nms_buf[r * cols + c] = 0.0f;
            }
        }
    }

    // 4. Hysteresis Double Thresholding
    // Pass 1: Mark Strong (255), Weak (1), Non-edge (0)
    for (int r = cent + 1; r < rows - cent - 1; r++) {
        #pragma HLS loop_tripcount min=128 max=1024 avg=512
        for (int c = cent + 1; c < cols - cent - 1; c++) {
            #pragma HLS loop_tripcount min=128 max=1024 avg=512
            float val = nms_buf[r * cols + c];
            if (val >= high_thresh) dst[r * cols + c] = 255;
            else if (val >= low_thresh) dst[r * cols + c] = 1;
            else dst[r * cols + c] = 0;
        }
    }

    // Pass 2: Hardware-friendly iterative edge tracking (replaces recursion)
    for (int iter = 0; iter < 5; iter++) {
        #pragma HLS loop_tripcount min=128 max=1024 avg=512 
        for (int r = cent + 2; r < rows - cent - 2; r++) {
            #pragma HLS loop_tripcount min=128 max=1024 avg=512
            for (int c = cent + 2; c < cols - cent - 2; c++) {
                #pragma HLS loop_tripcount min=128 max=1024 avg=512
                if (dst[r * cols + c] == 1) {
                    bool connected = false;
                    for (int i = -1; i <= 1; i++) {
                        #pragma HLS loop_tripcount min=128 max=1024 avg=512
                        for (int j = -1; j <= 1; j++) {
                            #pragma HLS loop_tripcount min=128 max=1024 avg=512
                            if (dst[(r + i) * cols + (c + j)] == 255) {
                                connected = true;
                            }
                        }
                    }
                    if (connected) dst[r * cols + c] = 255;
                }
            }
        }
    }

    // Pass 3: Clean up remaining un-connected weak edges
    for (int r = cent + 1; r < rows - cent - 1; r++) {
        #pragma HLS loop_tripcount min=128 max=1024 avg=512
        for (int c = cent + 1; c < cols - cent - 1; c++) {
            #pragma HLS loop_tripcount min=128 max=1024 avg=512
            if (dst[r * cols + c] == 1) dst[r * cols + c] = 0;
        }
    }
}