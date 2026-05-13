# Canny Edge Detection Benchmark Project


## Platform
* Target Hardware (future stages): Zynq / PYNQ Board

---

# Project Overview

This project implements a simple Canny Edge Detection pipeline in C++ using OpenCV.

The main goal of the current assignment is to study the relationship between:

* image size
* processing time

The benchmark measures the execution time of the Canny algorithm for different image resolutions and multiple benchmark images.

---

# Project Directory Structure

```text
canny/
├── CMakeLists.txt
├── README.md
├── script.py
├── images/
│   ├── lena.jpg
│   ├── baboon.jpg
│   ├── fruits.jpg
│   └── building.jpg
├── output/
├── results/
│   └── timing_results.csv
├── build/
└── src/
    └── main.cpp
    
```

---

# Dependencies

## C++

* OpenCV
* CMake
* Clang Compiler

## Python

* matplotlib
* pandas

Install Python dependencies:

```bash
pip3 install matplotlib pandas
```

---

# Build Instructions

## Create build directory

```bash
mkdir build
cd build
```

## Configure project

```bash
cmake .. \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++
```

## Build

```bash
cmake --build .
```

## Run benchmark

```bash
./canny
```

---

# Task 1 — Image Size vs Processing Time

## Objective

Measure the processing time of the Canny Edge Detection algorithm for different image sizes.

## Tested Image Sizes

* 128 × 128
* 256 × 256
* 512 × 512
* 1024 × 1024

## Benchmark Images

* lena.jpg
* baboon.jpg
* fruits.jpg
* building.jpg

## Methodology

1. Load grayscale image.
2. Resize image to target resolution.
3. Apply Canny Edge Detection.
4. Measure execution time using `std::chrono`.
5. Repeat execution multiple times.
6. Compute average processing time.
7. Save timing results to CSV.
8. Generate performance graph using Python.

---

# Example Benchmark Output

```text
Processing: lena.jpg
128x128 -> 66 us
256x256 -> 167 us
512x512 -> 335 us
1024x1024 -> 647 us
```

---

# Performance Visualization

The benchmark results are plotted using Matplotlib.

Run:

```bash
python3 src/script.py
```

The graph shows:

* X-axis: image size
* Y-axis: processing time (microseconds)

---

