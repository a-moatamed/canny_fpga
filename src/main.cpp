#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream>
#include <chrono>
#include <vector>
#include <filesystem>
#include "canny.hpp"

using namespace std;

int main()
{
    vector<int> sizes = {128, 256, 512, 1024};
    string imageDir = "../images";
    string outputDir = "../output";

    ofstream results("../results/timing_results_naive.csv");
    results << "image,size,time_us\n";

    for (const auto& entry : filesystem::directory_iterator(imageDir))
    {
        if (!entry.is_regular_file()) continue;

        string imageName = entry.path().filename().string();
        cv::Mat original = cv::imread(entry.path().string(), cv::IMREAD_GRAYSCALE);

        if (original.empty()) continue;

        cout << "\nProcessing: " << imageName << endl;

        for (int size : sizes)
        {
            cv::Mat resized;
            cv::resize(original, resized, cv::Size(size, size));

            int rows = resized.rows;
            int cols = resized.cols;

            // Output image initialized to black (0)
            cv::Mat edges(rows, cols, CV_8U, cv::Scalar(0));
            
            // Allocate flat 1D arrays to simulate intermediate FPGA memory buffers
            float* x_buf   = new float[rows * cols]();
            float* y_buf   = new float[rows * cols]();
            float* mag_buf = new float[rows * cols]();
            float* nms_buf = new float[rows * cols]();

            auto start = chrono::high_resolution_clock::now();

            canny_fpga_naive(
                resized.data, edges.data, 
                x_buf, y_buf, mag_buf, nms_buf, 
                rows, cols, 50.0f, 150.0f
            );

            auto stop = chrono::high_resolution_clock::now();
            auto duration = chrono::duration_cast<chrono::microseconds>(stop - start);

            string outPath = outputDir + "/fpga_naive_" + imageName + "_" + to_string(size) + ".png";
            cv::imwrite(outPath, edges);

            cout << size << "x" << size << " -> " << duration.count() << " us\n";
            results << imageName << "," << size << "," << duration.count() << "\n";

            // Free memory to prevent leaks
            delete[] x_buf;
            delete[] y_buf;
            delete[] mag_buf;
            delete[] nms_buf;
        }
    }
    results.close();
    cout << "\nBenchmark finished.\n";
    return 0;
}