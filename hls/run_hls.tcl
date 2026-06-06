# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa



# Open/Create the project
open_project -reset canny_edge_detector 

# Set the exact name of your top-level C++ function
set_top canny_fpga_naive 

# Add the hardware source code
# Note: we add the include path so it finds canny.hpp
add_files src/canny.cpp -cflags "-I./include"

# Add the testbench
add_files -tb tb/tb_canny.cpp -cflags "-I./include"

# Create a solution and set the PYNQ-Z2 part
open_solution -reset sol1 
set_part {xc7z020clg400-1}
create_clock -period 10 -name default

# Skip csim for now, go straight to synthesis
# csim_design 
csynth_design

# Export the IP core
export_design -format ip_catalog

exit
