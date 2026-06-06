cmake_minimum_required(VERSION 3.10)


project(CannyTiming)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# find_package(OpenCV REQUIRED)

# The host executable that you run for timing comparisons
add_executable(canny_host hls/src/main.cpp hls/src/canny.cpp hls/tb/tb_canny.cpp)
target_include_directories(canny_host PRIVATE hls/include)
target_link_libraries(canny_host ${OpenCV_LIBS})

# 1. FPGA Synthesis Target (HLS)
add_custom_target(synthesize
    COMMAND ${CMAKE_SOURCE_DIR}/scripts/run_hls.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running FPGA HLS Synthesis..."
)

# 2. FPGA Hardware Implementation Target (Vivado)
add_custom_target(vivado
    COMMAND env HLS_IP_REPO=${CMAKE_SOURCE_DIR}/hls/canny_edge_detector/sol1/impl/export.zip ${CMAKE_SOURCE_DIR}/scripts/run_vivado.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running Vivado Implementation (This will take 10-15 minutes)..."
)

# 3. FPGA Packaging Target
add_custom_target(package
    COMMAND ${CMAKE_SOURCE_DIR}/scripts/package_overlay.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Packaging IP Core..."
)