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

    ofstream results("../results/timing_results.csv");
    results << "image,size,time_us\n";

    for (const auto& entry : filesystem::directory_iterator(imageDir))
    {
        if (!entry.is_regular_file()) continue;

        string imageName = entry.path().filename().string();
        cv::Mat original = cv::imread(entry.path().string(), cv::IMREAD_GRAYSCALE);

        if (original.empty())
        {
            cout << "Failed to load: " << imageName << endl;
            continue;
        }

        cout << "\nProcessing: " << imageName << endl;

        for (int size : sizes)
        {
            cv::Mat resized;
            cv::resize(original, resized, cv::Size(size, size));

            auto start = chrono::high_resolution_clock::now();

            cv::Mat edges = customCanny(resized);

            auto stop = chrono::high_resolution_clock::now();

            auto duration =
                chrono::duration_cast<chrono::microseconds>(stop - start);

            string outPath = outputDir + "/edge_" + imageName + "_" + to_string(size) + ".png";
            cv::imwrite(outPath, edges);

            cout << size << "x" << size << " -> " << duration.count() << " us\n";

            results << imageName << "," << size << "," << duration.count() << "\n";
        }
    }

    results.close();
    cout << "\nBenchmark finished.\n";
    return 0;
}

