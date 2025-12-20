`timescale 1ns/1ns

module alu (in1, in2, sel, out1);
  input  [7:0] in1, in2;
  input  [2:0] sel;
  output reg [7:0] out1;
  wire [7:0] out_and;
  wire [7:0] out_or;
  wire [7:0] out_xor;
  wire [7:0] out_xnor;
  and_cell  u_and  (.in1(in1), .in2(in2), .out1(out_and));
  or_cell   u_or   (.in1(in1), .in2(in2), .out1(out_or));
  xor_cell  u_xor  (.in1(in1), .in2(in2), .out1(out_xor));
  xnor_cell u_xnor (.in1(in1), .in2(in2), .out1(out_xnor));
  wire [7:0] out_add = in1 + in2;
  wire [7:0] out_sub = in1 - in2;
  wire [2:0] shamt   = in2[2:0];
  wire [7:0] out_sll = in1 << shamt;
  wire [7:0] out_srl = in1 >> shamt;
  always @(*) begin
    case (sel)
      3'b000: out1 = out_and;   // AND
      3'b001: out1 = out_or;    // OR
      3'b010: out1 = out_xor;   // XOR
      3'b011: out1 = out_xnor;  // XNOR
      3'b100: out1 = out_add;   // ADD
      3'b101: out1 = out_sub;   // SUB
      3'b110: out1 = out_sll;   // SLL
      3'b111: out1 = out_srl;   // SRL
      default: out1 = 8'h00;
    endcase
  end

endmodule


module and_cell (in1,in2,out1);
  input  [7:0] in1,in2;
  output [7:0] out1;
  assign out1 = in1 & in2;
endmodule

module or_cell (in1,in2,out1);
  input  [7:0] in1,in2;
  output [7:0] out1;
  assign out1 = in1 | in2;
endmodule

module xor_cell (in1,in2,out1);
  input  [7:0] in1,in2;
  output [7:0] out1;
  assign out1 = in1 ^ in2;
endmodule

module xnor_cell (in1,in2,out1);
  input  [7:0] in1,in2;
  output [7:0] out1;
  assign out1 = ~(in1 ^ in2);
endmodule
