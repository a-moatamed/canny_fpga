#include "canny.hpp"
#include <cmath>

/* ---------------- Gaussian Blur ---------------- */
cv::Mat gaussianBlur(const cv::Mat& img)
{
    cv::Mat blurred;
    cv::GaussianBlur(img, blurred, cv::Size(5, 5), 1.4);
    return blurred;
}

/* ---------------- Sobel Gradient ---------------- */
void computeGradient(const cv::Mat& img, cv::Mat& magnitude, cv::Mat& direction)
{
    cv::Mat gx, gy;

    cv::Sobel(img, gx, CV_32F, 1, 0, 3);
    cv::Sobel(img, gy, CV_32F, 0, 1, 3);

    magnitude = cv::Mat(img.size(), CV_32F);
    direction = cv::Mat(img.size(), CV_32F);

    for (int i = 0; i < img.rows; i++)
    {
        for (int j = 0; j < img.cols; j++)
        {
            float x = gx.at<float>(i, j);
            float y = gy.at<float>(i, j);

            magnitude.at<float>(i, j) = std::sqrt(x * x + y * y);
            direction.at<float>(i, j) = std::atan2(y, x);
        }
    }
}

/* -------- Non-Maximum Suppression -------- */
cv::Mat nonMaxSuppression(const cv::Mat& mag, const cv::Mat& dir)
{
    cv::Mat nms = cv::Mat::zeros(mag.size(), CV_32F);

    for (int i = 1; i < mag.rows - 1; i++)
    {
        for (int j = 1; j < mag.cols - 1; j++)
        {
            float angle = dir.at<float>(i, j) * 180.0f / CV_PI;
            if (angle < 0) angle += 180;

            float q = 255, r = 255;

            if ((0 <= angle && angle < 22.5) || (157.5 <= angle))
            {
                q = mag.at<float>(i, j + 1);
                r = mag.at<float>(i, j - 1);
            }
            else if (22.5 <= angle && angle < 67.5)
            {
                q = mag.at<float>(i + 1, j - 1);
                r = mag.at<float>(i - 1, j + 1);
            }
            else if (67.5 <= angle && angle < 112.5)
            {
                q = mag.at<float>(i + 1, j);
                r = mag.at<float>(i - 1, j);
            }
            else
            {
                q = mag.at<float>(i - 1, j - 1);
                r = mag.at<float>(i + 1, j + 1);
            }

            nms.at<float>(i, j) =
                (mag.at<float>(i, j) >= q && mag.at<float>(i, j) >= r)
                ? mag.at<float>(i, j)
                : 0;
        }
    }

    return nms;
}

/* -------- Hysteresis Thresholding -------- */
cv::Mat hysteresis(const cv::Mat& img, float low, float high)
{
    cv::Mat res = cv::Mat::zeros(img.size(), CV_8U);

    for (int i = 1; i < img.rows - 1; i++)
    {
        for (int j = 1; j < img.cols - 1; j++)
        {
            float val = img.at<float>(i, j);

            if (val >= high)
            {
                res.at<uchar>(i, j) = 255;
            }
            else if (val >= low)
            {
                bool connected = false;

                for (int x = -1; x <= 1 && !connected; x++)
                {
                    for (int y = -1; y <= 1; y++)
                    {
                        if (img.at<float>(i + x, j + y) >= high)
                        {
                            connected = true;
                            break;
                        }
                    }
                }

                if (connected)
                    res.at<uchar>(i, j) = 255;
            }
        }
    }

    return res;
}

/* -------- Full Pipeline -------- */
cv::Mat customCanny(const cv::Mat& img)
{
    cv::Mat blurred = gaussianBlur(img);

    cv::Mat mag, dir;
    computeGradient(blurred, mag, dir);

    cv::Mat nms = nonMaxSuppression(mag, dir);

    return hysteresis(nms, 50, 150);
}