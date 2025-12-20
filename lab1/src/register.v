`timescale 1ns/1ns

`celldefine
module register_1 (clk ,reset ,d ,q);
	
	input clk,reset;
	input  [7 : 0] d;
	output reg [7 : 0] q;
  
	always @ (posedge(clk) or negedge(reset))
	begin
	if (!reset)
		q <= 0;
	else
		q <= d;
	end
endmodule
`endcelldefine

`celldefine
module register_2 (clk ,reset ,d ,q);
	
	input clk,reset;
	input  [1 : 0] d;
	output reg [1 : 0] q;
  
	always @ (posedge(clk) or negedge(reset))
	begin
	if (!reset)
		q <= 0;
	else
		q <= d;
	end
endmodule
`endcelldefine


`celldefine
module register_3 (clk, reset, d, q);   
    input clk, reset;
    input [2:0] d;  // 3 位输入数据
    output reg [2:0] q;  // 3 位输出数据
    
    always @ (posedge clk or negedge reset) begin
        if (!reset)
            q <= 0;  // 如果复位，将输出置为0
        else
            q <= d;  // 否则，将输入数据 d 存入输出 q
    end
endmodule
`endcelldefine