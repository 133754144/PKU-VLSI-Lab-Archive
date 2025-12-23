module controller (
    input  wire       clk,
    input  wire       reset,     // 异步复位（active low）
    input  wire       start,     // 开始触发信号
    output reg        mem_CEB,   // RAM片选（低有效）
    output reg        mem_WEB,   // RAM读/写控制（低=写, 高=读）
    output reg  [7:0] mem_addr,  // RAM地址
    output reg        input_ld,  // ALU输入寄存器加载使能
    output reg        result_ld, // ALU结果寄存器加载使能
    output wire       done       // 完成信号，高电平有效
    );
    // 定义状态编码
    typedef enum reg [2:0] {
        S_IDLE  = 3'b000,  // 空闲等待
        S_EXEC1 = 3'b001,  // ALU执行阶段1
        S_EXEC2 = 3'b010,  // ALU执行阶段2（结果可用）
        S_WRITE = 3'b011,  // 写RAM阶段
        S_READ  = 3'b100,  // 读RAM阶段
        S_DONE  = 3'b101   // 完成阶段
    } state_t;
    state_t state, next_state;
    // 异步复位和状态寄存器更新
    always @(posedge clk or negedge reset) begin
        if (!reset) 
            state <= S_IDLE;
        else
            state <= next_state;
    end
    // 主状态机：组合逻辑决定下一状态和输出控制信号
    always @(*) begin
        // 默认输出信号值（避免不完全赋值导致锁存）
        next_state = state;
        mem_CEB    = 1'b1;
        mem_WEB    = 1'b1;
        input_ld   = 1'b0;
        result_ld  = 1'b0;
        // 默认情况下地址保持不变，必要时另行赋值
        next_mem_addr = mem_addr;
        case (state) 
            S_IDLE: begin
                // 等待开始命令
                if (start) begin
                    input_ld   = 1'b1;    // 锁存 ALU 输入
                    next_state = S_EXEC1; // 进入执行阶段1
                end
            end
            S_EXEC1: begin
                // ALU 运算进行中（等待一个周期）
                next_state = S_EXEC2; // 转到执行阶段2
            end
            S_EXEC2: begin
                // ALU结果已稳定
                result_ld = 1'b1; //锁存 ALU 结果
                // 准备写RAM：下一周期开始写
                next_state = S_WRITE;
            end
            S_WRITE: begin
                // 执行写RAM：激活RAM并设置为写模式
                mem_CEB    = 1'b0; // 注意CEB，0 = 有效
                mem_WEB    = 1'b0; // 注意WEB，0 = 写，1 = 读
                next_state = S_READ; // 下一周期转入读阶段
            end
            S_READ: begin
                // 执行读RAM
                mem_CEB    = 1'b0; // 保持有效
                mem_WEB    = 1'b1; // 读
                next_state = S_DONE; // 下一周期进入完成阶段
            end
            S_DONE: begin
                // 完成：停用RAM
                mem_CEB    = 1'b1;
                mem_WEB    = 1'b1;
                // 更新存储地址
                next_mem_addr = mem_addr + 8'd1;
                next_state = S_IDLE; // 返回空闲状态
            end
        endcase
    end
    // 地址寄存器：在复位时清零，在完成阶段更新地址（地址自增）
    reg [7:0] next_mem_addr;
    always @(posedge clk or negedge reset) begin
        if (!reset) // reset = 0 时有效
            mem_addr <= 8'd0;
        else
            mem_addr <= next_mem_addr;
    end
    // 当处于 DONE 状态时输出 done=1
    assign done = (state == S_DONE);
endmodule
