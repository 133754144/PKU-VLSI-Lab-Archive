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
    reg  [7:0]  exp; 
    integer     i;
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
    initial begin
        clk = 1'b0;
        forever #(PERIOD/2) clk = ~clk;
    end

    initial begin : MAIN_TEST

        in1     = 8'h00;
        in2     = 8'h00;
        sel     = 3'd0;
        start   = 1'b0;
        err_cnt = 0;
        reset = 1'b0;
        #(PERIOD/2);
        reset = 1'b1;
        #(PERIOD);
        $display("[TEST] Starting ALU->RAM sequence tests...");
        for (i = 0; i < 8; i = i + 1) begin
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
            start = 1'b1;
            #(PERIOD);
            start = 1'b0;
            @(posedge done);
            #1;
            if (out_data !== {8'h00, exp}) begin
                err_cnt = err_cnt + 1;
                $display("[ERROR] sel=%0d: in1=0x%02h, in2=0x%02h, out_data=0x%04h, expected=0x%04h",
                         sel, in1, in2, out_data, {8'h00, exp});
            end else begin
                $display("[OK] sel=%0d: Result correct (0x%04h == 0x%04h)",
                         sel, out_data, {8'h00, exp});
            end

            #(PERIOD);
        end 
        if (err_cnt == 0) begin
            $display("====== ALL TESTS PASSED: ALU->RAM operations are correct. ======");
        end else begin
            $display("====== TEST FAILED: %0d errors detected. ======", err_cnt);
        end

        $finish;
    end

endmodule
