`timescale 1ns/1ns
module mcu_tester;
    parameter PERIOD = 50;

    // DUT 接口信号
    reg         clk;
    reg         reset;
    reg  [7:0]  in1;
    reg  [7:0]  in2;
    reg  [2:0]  sel;
    reg         start;
    wire [15:0] out_data;
    wire        done;

    integer     err_cnt;
    reg  [7:0]  exp;  // 期望的8位结果
    integer     i;

    // 实例化顶层模块 DUT
    mcu_top dut (
        .clk      (clk),
        .reset    (reset),
        .in1      (in1),
        .in2      (in2),
        .sel      (sel),
        .start    (start),
        .out_data (out_data),
        .done     (done)
    );

    // 产生时钟信号
    initial begin
        clk = 1'b0;
        forever #(PERIOD/2) clk = ~clk;
    end

    // [修改1] 把“复位 + 全部测试流程”放进一个 initial 块里（修复模块级 #delay 语法错误）
    initial begin : MAIN_TEST
        // 初始化输入
        in1     = 8'h00;
        in2     = 8'h00;
        sel     = 3'd0;
        start   = 1'b0;
        err_cnt = 0;

        // 初始化：复位保持半个时钟周期，然后释放（你的注释说 active low，这里保持不变）
        reset = 1'b0;
        #(PERIOD/2);
        reset = 1'b1;
        #(PERIOD);

        $display("[TEST] Starting ALU->RAM sequence tests...");

        // [可选增强] 避免 done 初始为 X/1 导致误触发
        // wait(done === 1'b0);

        // 依次测试 ALU 的8种操作
        for (i = 0; i < 8; i = i + 1) begin
            // 设置当前测试的操作码和输入数据
            sel = i[2:0];
            case (sel)
                3'b000: begin in1 = 8'hAA;       in2 = 8'hCC; end   // AND
                3'b001: begin in1 = 8'hF0;       in2 = 8'h0F; end   // OR
                3'b010: begin in1 = 8'h96;       in2 = 8'h5A; end   // XOR
                3'b011: begin in1 = 8'h96;       in2 = 8'h5A; end   // XNOR
                3'b100: begin in1 = 8'd50;       in2 = 8'd25; end   // ADD
                3'b101: begin in1 = 8'd25;       in2 = 8'd50; end   // SUB
                3'b110: begin in1 = 8'b00001111; in2 = 8'd2;  end   // SLL
                3'b111: begin in1 = 8'b11110000; in2 = 8'd2;  end   // SRL
            endcase

            // 计算期望结果（模拟ALU逻辑）
            case (sel)
                3'b000: exp = in1 & in2;
                3'b001: exp = in1 | in2;
                3'b010: exp = in1 ^ in2;
                3'b011: exp = ~(in1 ^ in2);
                3'b100: exp = in1 + in2;
                3'b101: exp = in1 - in2;
                3'b110: exp = in1 << (in2[2:0]);
                3'b111: exp = in1 >> (in2[2:0]);
            endcase

            // 发起一次 ALU->RAM 操作序列：start 拉高 1 个周期
            start = 1'b1;
            #(PERIOD);
            start = 1'b0;   // [修改2] 原来是 0'b0，位宽错误

            // 等待操作完成信号 done = 1
            @(posedge done);
            #1;

            // 检查RAM输出数据是否匹配期望结果（注意 out_data 高8位应为0）
            if (out_data !== {8'h00, exp}) begin
                err_cnt = err_cnt + 1;
                $display("[ERROR] sel=%0d: in1=0x%02h, in2=0x%02h, out_data=0x%04h, expected=0x%04h",
                         sel, in1, in2, out_data, {8'h00, exp});
            end else begin
                $display("[OK] sel=%0d: Result correct (0x%04h == 0x%04h)",
                         sel, out_data, {8'h00, exp});
            end

            #(PERIOD);
        end // [修改3] for 循环的 end 放在这里，保证 8 次测试都跑完

        // [修改4] 测试总结与结束移到循环外（否则只测一次就结束）
        if (err_cnt == 0) begin
            $display("====== ALL TESTS PASSED: ALU->RAM operations are correct. ======");
        end else begin
            $display("====== TEST FAILED: %0d errors detected. ======", err_cnt);
        end

        $finish;
    end

endmodule
