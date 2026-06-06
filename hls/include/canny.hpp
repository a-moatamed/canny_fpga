#ifndef CANNY_HPP
#define CANNY_HPP

// Pure C++ function signature ready for High Level Synthesis (HLS)
void canny_fpga_naive(
    const unsigned char* src, unsigned char* dst, 
    float* x_buf, float* y_buf, float* mag_buf, float* nms_buf,
    int rows, int cols, float low_thresh, float high_thresh);

#endif // CANNY_HPP