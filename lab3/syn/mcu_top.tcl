# 设置库文件路径和使用的工艺库
set_attribute lib_search_path ../lib/timing_lib/smic
set_attribute library "smic35os142_typ.lib"

# 读取RTL源文件（顶层模块及依赖模块）
set_attribute hdl_search_path ../src
read_hdl mcu_top.v controller.v alu.v ram_256x16.v

# 指定顶层进行综合
elaborate mcu_top

# 定义时钟和I/O时序约束（根据顶层端口）
define_clock -name clk -period 100000 clk [get_pins mcu_top/clk]
external_delay -clock clk -input 10 reset
external_delay -clock clk -input 10 in1*
external_delay -clock clk -input 10 in2*
external_delay -clock clk -input 10 sel*
external_delay -clock clk -input 10 start
external_delay -clock clk -output 10 out_data*
external_delay -clock clk -output 10 done

# 执行逻辑综合和映射
syn_gen
syn_map

# 输出综合后的网表
write -mapped > mcu_top_netlist.v

# 报告时序与面积等信息
report_timing > mcu_top_timing.rpt
report_area   > mcu_top_area.rpt
write_sdc     > mcu_top_constraints.sdc

# 生成可重用综合脚本和SDF时序文件
write_script  > mcu_top_script.tcl
write_sdf -edges check_edge -setuphold split > mcu_top.sdf

quit
