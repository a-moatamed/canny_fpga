cmake_minimum_required(VERSION 3.10)


project(CannyTiming)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(OpenCV REQUIRED)

# The host executable that you run for timing comparisons
add_executable(canny_host hls/src/main.cpp hls/src/canny.cpp)
target_include_directories(canny_host PRIVATE hls/include)
target_link_libraries(canny_host ${OpenCV_LIBS})

# FPGA Synthesis Target
add_custom_target(synthesize
    COMMAND ${CMAKE_SOURCE_DIR}/scripts/run_hls.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running FPGA HLS Synthesis..."
)

# FPGA Packaging Target
add_custom_target(package
    COMMAND ${CMAKE_SOURCE_DIR}/scripts/package_overlay.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Packaging IP Core..."
)