`timescale 1ns/1ns
// Lab3 Micro Processing Unit Top Module
module mcu_top(
    input  wire        clk,
    input  wire        reset,   // active low
    input  wire [7:0]  in1,     // ALU操作数1
    input  wire [7:0]  in2,     // ALU操作数2
    input  wire [2:0]  sel,     
    input  wire        start,   
    output wire [15:0] out_data,
    output wire        done     
    );
    // 中间信号声明
    wire        mem_CEB;    // RAM片选使能（低有效）
    wire        mem_WEB;    // RAM读/写选择（低=写入, 高=读取）
    wire [7:0]  mem_addr;   // RAM地址总线
    wire [15:0] mem_din;    // RAM写入数据总线
    wire [15:0] mem_q;      // RAM输出数据总线
    reg  [7:0]  in1_reg;    // ALU输入寄存器1
    reg  [7:0]  in2_reg;    // ALU输入寄存器2
    reg  [2:0]  sel_reg;    // ALU操作码寄存器
    reg  [7:0]  result_reg; // ALU结果寄存器    
    controller ctrl_unit (
        .clk       (clk),
        .reset     (reset),
        .start     (start),
        .mem_CEB   (mem_CEB),
        .mem_WEB   (mem_WEB),
        .mem_addr  (mem_addr),
        .input_ld  (input_ld),
        .result_ld (result_ld),
        .done      (done)
    );
    wire [7:0] alu_out;
    alu alu_inst (
        .in1  (in1_reg),
        .in2  (in2_reg),
        .sel  (sel_reg),
        .out1 (alu_out)
    );
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            in1_reg <= 8'd0;
            in2_reg <= 8'd0;
            sel_reg <= 3'd0;
        end else if (input_ld) begin 
            in1_reg <= in1;
            in2_reg <= in2;
            sel_reg <= sel;
        end
    end
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            result_reg <= 8'd0;
        end else if (result_ld) begin
            result_reg <= alu_out;
        end
    end
    assign mem_din = {8'h00, result_reg};
    ram_256x16 u_ram (
        .clk  (clk),
        .CEB  (mem_CEB),
        .WEB  (mem_WEB),
        .RSTB (reset),    // 复位信号直接连接（低有效）
        .Addr (mem_addr),
        .Data (mem_din),
        .Q    (mem_q)
    );
    assign out_data = mem_q;
endmodule
