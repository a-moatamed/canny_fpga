# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa

if { $argc < 3 } {
  puts "Usage: vivado -mode batch -source vivado/build_overlay.tcl -tclargs <project_name> <part_name> <hls_ip_repo> [board_part]"
  exit 1
}

set project_name [lindex $argv 0]
set part_name [lindex $argv 1]
set hls_ip_repo [file normalize [lindex $argv 2]]
set board_part ""
if { $argc >= 4 } {
  set board_part [lindex $argv 3]
}

set build_dir [file normalize "vivado/build/${project_name}"]

create_project ${project_name} ${build_dir} -part ${part_name} -force
if { $board_part ne "" } {
  set_property board_part ${board_part} [current_project]
}

set_property ip_repo_paths [list ${hls_ip_repo}] [current_project]
update_ip_catalog

create_bd_design "design_1"

create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
  -config { make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } \
  [get_bd_cells processing_system7_0]

create_bd_cell -type ip -vlnv xilinx.com:hls:affine_accel:1.0 affine_accel_0

apply_bd_automation -rule xilinx.com:bd_rule:axi4 \
  -config { Clk "Auto" Master "/processing_system7_0/M_AXI_GP0" } \
  [get_bd_intf_pins affine_accel_0/s_axi_control]

validate_bd_design
save_bd_design

generate_target all [get_files design_1.bd]
make_wrapper -files [get_files design_1.bd] -top

set wrapper_v [glob -nocomplain "${build_dir}/${project_name}.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v"]
if {[llength $wrapper_v] == 0} {
  puts "ERROR: Could not locate design_1_wrapper.v"
  exit 1
}
add_files -norecurse [lindex $wrapper_v 0]
update_compile_order -fileset sources_1

launch_runs impl_1 -to_step write_bitstream -jobs 1
wait_on_run impl_1

set bit_files [glob -nocomplain "${build_dir}/${project_name}.runs/impl_1/*.bit"]
if {[llength $bit_files] == 0} {
  puts "ERROR: Bitstream not found."
  exit 1
}
puts "Bitstream: [lindex $bit_files 0]"

set hwh_files [glob -nocomplain "${build_dir}/${project_name}.gen/sources_1/bd/design_1/hw_handoff/*.hwh"]
if {[llength $hwh_files] == 0} {
  puts "ERROR: HWH not found."
  exit 1
}
puts "HWH: [lindex $hwh_files 0]"

exit
