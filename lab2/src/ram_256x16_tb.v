`timescale 1ns/1ns
module ram_tester;
	parameter period = 50;
    // DUT I/O
    reg CLK, CEB, WEB, RSTB;
    reg [7:0] Addr;
    reg [15:0] Data;
    wire [15:0] Q;
    reg [15:0] golden [0:255];
    integer i, err_cnt;
    // DUT
    ram_256x16 dut (.CLK(CLK), .CEB(CEB), .WEB(WEB), .RSTB(RSTB), .Addr(Addr), .Data(Data), .Q(Q));
    // Clock
    initial begin
        CLK = 1'b0;
        forever #(period/2) CLK = ~CLK;
    end
    // -------- task: write one word (CEB=0, WEB=0) --------
    task do_write(input [7:0] a, input [15:0] d);
        begin
            @(negedge CLK);
            CEB <= 1'b0;
            WEB <= 1'b0; // activate
            Addr <= a;
            Data <= d;
            @(posedge CLK);
            #1;
            golden[a] = d;
            WEB <= 1'b1; // disable write
        end
    endtask
    // -------- task: read one word (CEB=0, WEB=1) and compare --------
    task do_read_check(input [7:0] a);
        reg [15:0] exp;
        begin
            exp = golden[a];
            @(negedge CLK);
            CEB  <= 1'b0;
            WEB  <= 1'b1; // read
            Addr <= a;
            @(posedge CLK);
            #1;
            if (Q !== exp) begin
                err_cnt = err_cnt + 1;
                $display("[ERROR][%0t] READ Addr=0x%02h, Q=0x%04h, EXP=0x%04h",$time, a, Q, exp);
            end
        end
    endtask
    // -------- task: try write while chip disabled (CEB=1) --------
    task do_write_disabled(input [7:0] a, input [15:0] d);
        reg [15:0] q_before;
        begin
            q_before = Q;
            @(negedge CLK);
            CEB  <= 1'b1; // disable
            WEB  <= 1'b0; // activate
            Addr <= a;
            Data <= d;
            @(posedge CLK);
            #1;
            if (Q !== q_before) begin
                err_cnt = err_cnt + 1;
                $display("[ERROR][%0t] DISABLED-WRITE changed Q! before=0x%04h after=0x%04h",$time, q_before, Q);
            end
            @(negedge CLK);
            WEB <= 1'b1;
        end
    endtask
    // -------- task: read while chip disabled (CEB=1) --------
    task do_read_disabled(input [7:0] a);
        reg [15:0] q_before;
        begin
            q_before = Q;
            @(negedge CLK);
            CEB  <= 1'b1; // disable
            WEB  <= 1'b1; // read
            Addr <= a;
            @(posedge CLK);
            #1;
            if (Q !== q_before) begin
                err_cnt = err_cnt + 1;
                $display("[ERROR][%0t] DISABLED-READ changed Q! before=0x%04h after=0x%04h",$time, q_before, Q);
            end
        end
    endtask
    // waveform
    initial begin
        $shm_open("ram_test.shm");
        $shm_probe("AC");
    end
    // main stimulus
    initial begin
        err_cnt = 0;
        // init signals
        CEB  <= 1'b1; // disable
        WEB  <= 1'b1; // read
        Addr <= 8'h00;
        Data = 16'h0000;
        for (i = 0; i < 256; i = i + 1)
        golden[i] = 16'h0000;
        RSTB = 1'b0;
        #(period);
        RSTB = 1'b1;
        #(period);
        for (i = 8'h01; i < 8'hA0; i = i + 1) begin
            do_write(i[7:0], {8'h00, i[7:0]});
        end
        for (i = 8'h01; i <= 8'hA0; i = i + 1) begin
            do_read_check(i[7:0]);
        end
        do_write_disabled(8'h55, 16'h1234);
        do_read_check(8'h55);
        do_read_disabled(8'h66);
        RSTB = 1'b0;
        for (i = 0; i < 256; i = i + 1)
        golden[i] = 16'h0000;
        #(period);
        RSTB = 1'b1;
        #(period);
        do_read_check(8'h01);
        do_read_check(8'h55);
        do_read_check(8'hA0);
        if (err_cnt == 0) begin
            $display("========== RAM TEST PASS ==========");
        end else begin
            $display("========== RAM TEST FAIL: %0d errors ==========", err_cnt);
        end
        #(period);
        $finish;
    end
endmodule
