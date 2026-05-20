cmake_minimum_required(VERSION 3.10)


project(CannyTiming)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(OpenCV REQUIRED)

add_executable(canny src/main.cpp src/canny.cpp)
target_include_directories(canny PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_link_libraries(canny ${OpenCV_LIBS})