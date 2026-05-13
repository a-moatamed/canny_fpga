cmake_minimum_required(VERSION 3.10)

project(CannyTiming)

set(CMAKE_CXX_STANDARD 11)

find_package(OpenCV REQUIRED)

add_executable(canny src/main.cpp)

target_link_libraries(canny ${OpenCV_LIBS})