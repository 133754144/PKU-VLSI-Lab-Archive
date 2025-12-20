`timescale 1ns/1ns

module rtl_top (clk,reset,in1,in2,sel,out1);
	input clk, reset;
	input [7:0] in1, in2;
	input [2:0] sel;
	output [7:0] out1;

	//-----------------------------------------------
	// insert RTL components
	//-----------------------------------------------

	// intermediate signals for instances
	wire [7:0] in1_del,in2_del,out_alu;
	wire [2:0] sel_del;
	
	// register for in1
	register_1 in1_reg (.clk (clk),
	.reset (reset),
	.d (in1),
	.q (in1_del)); 

	// register for in2
	register_1 in2_reg (.clk (clk),
	.reset (reset),
	.d (in2),
	.q (in2_del));

	// register for sel
	register_3 sel_reg (.clk (clk),
	.reset (reset),
	.d (sel),
	.q (sel_del));

	// alu
	alu alu_inst (.in1(in1_del),
	.in2(in2_del),
	.sel(sel_del),
	.out1(out_alu));

	// register for out1 
	register_1 out1_reg (.clk (clk),
	.reset (reset),
	.d (out_alu),
	.q (out1));


endmodule
