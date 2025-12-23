`timescale 1ns/1ns
// Lab3 Micro Processing Unit Top Module
module mcu_top(
    input  wire        clk,
    input  wire        reset,   // 异步复位，active low
    input  wire [7:0]  in1,     // ALU操作数1
    input  wire [7:0]  in2,     // ALU操作数2
    input  wire [2:0]  sel,     // ALU操作码
    input  wire        start,   // 开始信号，高电平触发一次操作
    output wire [15:0] out_data,// 从RAM读出的16位数据
    output wire        done     // 完成信号，高电平表示一次操作完成
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
    // 实例化控制单元
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
    // 实例化 ALU 运算单元
    wire [7:0] alu_out;
        alu alu_inst (
            .in1  (in1_reg),
            .in2  (in2_reg),
            .sel  (sel_reg),
            .out1 (alu_out)
        );
