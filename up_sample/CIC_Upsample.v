module clc (
    input clk_in,                        // 输入数据时钟
    input clk_out,                       // 输出数据时钟（32 倍于 clk_in）
    input reset,                         // 复位信号
    input signed [15:0] data_in,        // 输入数据
    output reg signed [15:0] data_out,  // 输出数据
    output reg signed [15:0] comb_out,  // 梳状滤波器输出
    output reg signed [15:0] interpolation_out // 插值输出
);
    parameter STAGES = 5;               // 滤波器阶数改为 5
    parameter DATA_WIDTH = 16;          // 数据宽度
    parameter INDATA_WIDTH = DATA_WIDTH + 19; // 中间数据宽度，增加6位以防止溢出
    parameter Ntimer = 32;              // 插值倍数

    // 积分器的寄存器
    reg signed [INDATA_WIDTH-1:0] integrator [0:STAGES-1]; 
    // 梳状器的寄存器
    reg signed [INDATA_WIDTH-1:0] comb [0:STAGES-1]; 
    reg signed [INDATA_WIDTH-1:0] combd [0:STAGES-1]; 
    // 插值的寄存器
    reg signed [INDATA_WIDTH-1:0] interpolation = 0;
    reg [4:0] cont; // 计数器，用于控制插值
    // 输出缓冲
    reg signed [INDATA_WIDTH-1:0] output_buffer = 0;

    // 将输出缓冲的值映射到输出端口
    always @(posedge clk_out) begin
        data_out <= output_buffer[INDATA_WIDTH-1:INDATA_WIDTH-DATA_WIDTH]; // 调整以适应实际的位宽和动态范围
    end

    // 将梳状滤波器输出值映射到输出端口
    always @(posedge clk_in) begin
        comb_out <= comb[STAGES-1][INDATA_WIDTH-1:INDATA_WIDTH-DATA_WIDTH]; // 调整以适应实际的位宽和动态范围
    end

    // 将插值后的信号映射到输出端口
    always @(posedge clk_out) begin
        interpolation_out <= interpolation[INDATA_WIDTH-1:INDATA_WIDTH-DATA_WIDTH]; // 调整以适应实际的位宽和动态范围
    end

    // 梳状器（由输入时钟驱动）
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            // 清零所有寄存器
            comb[0] <= 0;
            combd[0] <= 0;
            comb[1] <= 0;
            combd[1] <= 0;
            comb[2] <= 0;
            combd[2] <= 0;
            comb[3] <= 0;
            combd[3] <= 0;
            comb[4] <= 0;
            combd[4] <= 0;
        end 
        else begin
            // 梳状器操作
            comb[0] <= {{(INDATA_WIDTH-DATA_WIDTH){data_in[DATA_WIDTH-1]}}, data_in};
            combd[0] <= comb[0]; // 第一项的上一个值
            comb[1] <= comb[0] - combd[0];
            combd[1] <= comb[1];
            comb[2] <= comb[1] - combd[1];
            combd[2] <= comb[2];
            comb[3] <= comb[2] - combd[2];
            combd[3] <= comb[3];
            comb[4] <= comb[3] - combd[3];
            combd[4] <= comb[4];
        end
    end

    // 插值器(输出时钟驱动)
    always @(posedge clk_out or posedge reset) begin
        if (reset) begin
            interpolation <= 0;
            cont <= 0;
        end 
        else begin
            cont <= cont + 1;
            if (cont == Ntimer - 1) begin // 每 32 个输出时钟周期，输出一次插值信号
                interpolation <= comb[STAGES-1];
                cont <= 0;
            end
            else
                interpolation <= 0; // 其它周期输出 0
        end
    end

    // 积分器逻辑（由输出时钟驱动）
    always @(posedge clk_out or posedge reset) begin
        if (reset) begin
            // 清零所有积分器寄存器
            integrator[0] <= 0;
            integrator[1] <= 0;
            integrator[2] <= 0;
            integrator[3] <= 0;
            integrator[4] <= 0;
            output_buffer <= 0;
        end 
        else begin
            integrator[0] <= interpolation;
            integrator[1] <= integrator[0] + integrator[1];
            integrator[2] <= integrator[1] + integrator[2];
            integrator[3] <= integrator[2] + integrator[3];
            integrator[4] <= integrator[3] + integrator[4];
            output_buffer <= integrator[STAGES-1];
        end
    end

endmodule