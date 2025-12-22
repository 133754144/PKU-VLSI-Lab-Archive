# Set the library path and define the library to use
set_attribute lib_search_path ../lib/timing_lib/smic
set_attribute library "smic35os142_typ.lib"

# Read the RTL files, including the top module and all dependencies
set_attribute hdl_search_path ../src
read_hdl ram_256x16.v ram_256x16_tb.v 

# Elaborate the top design (this is where the actual synthesis happens)
elaborate ram_256x16  
# Define the clock for the design, make sure it references the correct top module's clock
define_clock -name clk -period 3900 clk  [get_pins ram_256x16/clk]

# Define external delays (I/O timing constraints) for the RAM module's interface
external_delay -clock clk -input 10 RSTB
external_delay -clock clk -input 10 Addr*
external_delay -clock clk -input 10 Data*
external_delay -clock clk -output 10 Q*

# Synthesize the design
syn_gen

# Map the design (map it to the target technology)
syn_map

# Output the synthesized netlist
write -mapped > ram_256x16_netlist.v

# Generate timing and area reports
report_timing > ram_256x16_timing.rpt
report_area > ram_256x16_area.rpt

# Generate the SDC (Synopsys Design Constraints) file
write_sdc > ram_256x16_constraints.sdc

# Generate the TCL script for the synthesis process
write_script > ram_256x16_script.tcl

# Generate SDF (Standard Delay Format) file for post-synthesis simulation
write_sdf -edges check_edge -setuphold split > ram_256x16.sdf

# End the synthesis process
quit
