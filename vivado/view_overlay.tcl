# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa

if { $argc < 1 } {
  puts "Usage: vivado -mode tcl -source vivado/view_overlay.tcl -tclargs <project_name> [bd|impl|project]"
  exit 1
}

set project_name [lindex $argv 0]
set view "bd"
if { $argc >= 2 } {
  set view [lindex $argv 1]
}

set build_dir [file normalize "vivado/build/${project_name}"]
set project_xpr [file normalize "${build_dir}/${project_name}.xpr"]

if { ![file exists ${project_xpr}] } {
  puts "ERROR: Project not found: ${project_xpr}"
  puts "Run scripts/run_vivado.sh first."
  exit 1
}

open_project ${project_xpr}
start_gui

if { $view eq "bd" } {
  set bd_files [get_files -quiet -filter {FILE_TYPE == "Block Designs"}]
  if {[llength $bd_files] == 0} {
    puts "ERROR: No block design found in project."
    exit 1
  }
  open_bd_design [lindex $bd_files 0]
  puts "Opened block design view."
} elseif { $view eq "impl" } {
  open_run impl_1
  puts "Opened implemented design run (impl_1)."
} elseif { $view eq "project" } {
  puts "Opened project only."
} else {
  puts "ERROR: Unknown view '${view}'. Use one of: bd, impl, project"
  exit 1
}
