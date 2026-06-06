# vivado/build_overlay.tcl

# 1. Read Arguments from run_vivado.sh
set proj_name [lindex $argv 0]
set part_name [lindex $argv 1]
set hls_ip_repo [lindex $argv 2]

# 2. Setup Project
set proj_dir "./build/$proj_name"
create_project -force $proj_name $proj_dir -part $part_name

# 3. Add HLS IP Repository (Using the absolute path passed by bash)
set_property ip_repo_paths $hls_ip_repo [current_project]
update_ip_catalog

# 4. Create Block Design
create_bd_design $proj_name

# 5. Add Zynq Processing System (The ARM Processor)
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# Enable High-Performance Port (HP0) so the FPGA can access the external DDR memory
set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1}] [get_bd_cells processing_system7_0]

# 6. Add Your Custom Canny IP
create_bd_cell -type ip -vlnv xilinx.com:hls:canny_fpga_naive:1.0 canny_fpga_naive_0

# 7. Run Connection Automation (Automatically draws the AXI wires)
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/canny_fpga_naive_0/s_axi_CTRL} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins canny_fpga_naive_0/s_axi_CTRL]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/canny_fpga_naive_0/s_axi_control} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins canny_fpga_naive_0/s_axi_control]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/canny_fpga_naive_0/m_axi_gmem} Slave {/processing_system7_0/S_AXI_HP0} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]

# 8. Create Wrapper and Generate Bitstream
make_wrapper -files [get_files $proj_dir/${proj_name}.srcs/sources_1/bd/$proj_name/${proj_name}.bd] -top
add_files -norecurse $proj_dir/${proj_name}.srcs/sources_1/bd/$proj_name/hdl/${proj_name}_wrapper.v
set_property top ${proj_name}_wrapper [current_fileset]

# Launch Synthesis and Implementation
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

exit
