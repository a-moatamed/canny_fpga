#ifndef CANNY_H
#define CANNY_H

#include <opencv2/opencv.hpp>

cv::Mat gaussianBlur(const cv::Mat& img);

void computeGradient(const cv::Mat& img,
                     cv::Mat& magnitude,
                     cv::Mat& direction);

cv::Mat nonMaxSuppression(const cv::Mat& mag,
                          const cv::Mat& dir);

cv::Mat hysteresis(const cv::Mat& img,
                   float low,
                   float high);

cv::Mat customCanny(const cv::Mat& img);

#endif // CANNY_H