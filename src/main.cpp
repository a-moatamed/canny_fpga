#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream>
#include <chrono>
#include <vector>

using namespace cv;
using namespace std;
using namespace std::chrono;

int main()
{
    vector<int> sizes = {128, 256, 512, 1024};

    vector<string> imageNames =
    {
        "lena.jpg",
        "baboon.jpg",
        "fruits.jpg",
        "building.jpg"
    };

    ofstream resultFile("../results/timing_results.csv");

    resultFile << "image,size,avg_time_us\n";

    int iterations = 30; // IMPORTANT for stable timing

    for (const string& imageName : imageNames)
    {
        string imagePath = "../images/" + imageName;

        Mat original = imread(imagePath, IMREAD_GRAYSCALE);

        if (original.empty())
        {
            cout << "Failed to load: " << imageName << endl;
            continue;
        }

        cout << "\nProcessing: " << imageName << endl;

        for (int size : sizes)
        {
            Mat resized;
            resize(original, resized, Size(size, size));

            Mat edges;

            long long totalTime = 0;

            // Warm-up (important for caching)
            Canny(resized, edges, 100, 200);

            for (int i = 0; i < iterations; i++)
            {
                auto start = high_resolution_clock::now();

                Canny(resized, edges, 100, 200);

                auto stop = high_resolution_clock::now();

                totalTime += duration_cast<microseconds>(stop - start).count();
            }

            long long avgTime = totalTime / iterations;

            cout << size << "x" << size
                 << " -> " << avgTime << " us" << endl;

            resultFile << imageName << ","
                       << size << ","
                       << avgTime << "\n";

            // Save output image (optional but good for report)
            string outputName = "../output/" + imageName + "_" + to_string(size) + ".png";
            imwrite(outputName, edges);
        }
    }

    resultFile.close();

    cout << "\nFinished benchmarking.\n";

    return 0;
}