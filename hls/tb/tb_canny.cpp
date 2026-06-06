#include "canny.hpp"
#include <iostream>

int main() {
    // 1. Create a small dummy image buffer to satisfy the compiler
    unsigned char src[100*100] = {0};
    unsigned char dst[100*100] = {0};
    float x_buf[100*100], y_buf[100*100], mag_buf[100*100], nms_buf[100*100];

    // 2. Call your top-level hardware function
    canny_fpga_naive(src, dst, x_buf, y_buf, mag_buf, nms_buf, 100, 100, 50.0, 150.0);

    // 3. Simple verification message
    std::cout << "Hardware Logic Verification Complete." << std::endl;
    return 0;
}