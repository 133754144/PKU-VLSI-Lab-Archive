`timescale 1ns/1ns

module alu_tester;

	parameter period = 50;

	// DUT inputs & outputs
	reg clk, reset;
	wire [7:0] out1;
	reg [7:0] in1,in2;
	reg [2:0] sel;

	// Device under test
	rtl_top dut (
	.clk(clk),
	.reset(reset),
	.in1(in1),
	.in2(in2),
	.sel(sel),
	.out1(out1));

	// clock generator #1
	initial begin
		clk <= 1'b0;
		forever #(period/2) clk = ~clk;
	end

	// Simulation control
	initial begin
		reset = 1'b0;
		in1 = 8'b0;
		in2 = 8'b0;
		#period in1 = 8'b01010101;
			in2 = 8'b11001100;
			sel = 3'b000;
		#period reset = 1'b1;
		//--------------------------------------------------------------------
		// Changing the arthematic operations
		//--------------------------------------------------------------------
		#period  sel = 3'b001;
		#period  sel = 3'b010;
		#period  sel = 3'b011;
		#period  sel = 3'b100;
		#period  sel = 3'b101;
		#period  sel = 3'b110;
		#period  sel = 3'b111;
		#period  $finish; // Need plus time
	end
	//display inputs & outputs as waveform
        initial
	        begin
			$shm_open("alu_test.shm");
			$shm_probe("AC");
		end
endmodule
