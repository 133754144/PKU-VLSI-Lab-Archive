#setup library
set_attribute lib_search_path ../lib/timing_lib/smic
set_attribute library "smic35os142_typ.lib"

#read_rtl
set_attribute hdl_search_path ../src
read_hdl top_rtl.v alu.v mux.v register.v
elaborate rtl_top

#timing constraints
define_clock -name clk -period 1700 clk
external_delay -clock clk -input 10 reset
external_delay -clock clk -input 10 in1*
external_delay -clock clk -input 10 in2*
external_delay -clock clk -input 10 sel*
external_delay -clock clk -output 10 out1*

#synthesize
syn_gen
syn_map


#output netlist
write -mapped > alu_netlist.v

#report
report timing > alu_timing.rpt
report area > alu_area.rpt
write_sdc > alu_constraints.sdc
write_script > alu_script.tcl

#output sdf
write_sdf -edges check_edge -setuphold split > alu.sdf

quit

