`timescale 1ns/1ns
module controller (
    input  wire       clk,
    input  wire       reset,     
    input  wire       start,     
    output reg        mem_CEB,   
    output reg        mem_WEB,   
    output reg  [7:0] mem_addr,  
    output reg        input_ld, 
    output reg        result_ld, 
    output wire       done      
    );
    localparam [2:0] 
        S_IDLE  = 3'b000,  
        S_EXEC1 = 3'b001, 
        S_EXEC2 = 3'b010, 
        S_WRITE = 3'b011, 
        S_READ  = 3'b100,  
        S_DONE  = 3'b101; 
    reg [2:0] state, next_state;
    reg [7:0] next_mem_addr;
    always @(posedge clk or negedge reset) begin
        if (!reset) 
            state <= S_IDLE;
        else
            state <= next_state;
    end
    always @(*) begin
        next_state = state;
        mem_CEB    = 1'b1;
        mem_WEB    = 1'b1;
        input_ld   = 1'b0;
        result_ld  = 1'b0;
        next_mem_addr = mem_addr;
        case (state) 
            S_IDLE: begin
                if (start) begin
                    input_ld   = 1'b1;    
                    next_state = S_EXEC1;
                end
            end
            S_EXEC1: begin
                next_state = S_EXEC2; 
            end
            S_EXEC2: begin
                result_ld = 1'b1; 
                next_state = S_WRITE;
            end
            S_WRITE: begin
                mem_CEB    = 1'b0; 
                mem_WEB    = 1'b0;
                next_state = S_READ; 
            end
            S_READ: begin
                mem_CEB    = 1'b0; // 保持有效
                mem_WEB    = 1'b1; // 读
                next_state = S_DONE;
            end
            S_DONE: begin
                mem_CEB    = 1'b1;
                mem_WEB    = 1'b1;
                next_mem_addr = mem_addr + 8'd1;
                next_state = S_IDLE;
            end
            default: begin
                next_state     = S_IDLE;
                next_mem_addr  = 8'd0;
                mem_CEB        = 1'b1;
                mem_WEB        = 1'b1;
                input_ld       = 1'b0;
                result_ld      = 1'b0;
            end
        endcase
    end
    always @(posedge clk or negedge reset) begin
        if (!reset) // reset = 0 时有效
            mem_addr <= 8'd0;
        else
            mem_addr <= next_mem_addr;
    end
    assign done = (state == S_DONE);
endmodule
