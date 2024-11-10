
`timescale 1ns / 1ps

module freq_div40k_tb;

    // 参数定义
    localparam CLK_PERIOD = 20; // 50MHz 的周期为 20ns
    localparam SIM_TIME = 2000000; // 仿真时间，2ms 足够观察输出

    // 输入信号
    reg clk;
    reg rst_n;

    // 输出信号
    wire freq_40k;

    // 实例化分频器模块
    freq_div40k #(.CNT_MAX(1000)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .freq_40k(freq_40k)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // 复位信号生成
    initial begin
        rst_n = 0; // 先拉低复位信号
        #40; // 持续 40ns 复位
        rst_n = 1; // 释放复位信号
    end

    // 仿真监测输出
    initial begin
        $monitor("Time: %0t | freq_40k: %b", $time, freq_40k);
        #(SIM_TIME) $finish; // 仿真结束
    end

endmodule