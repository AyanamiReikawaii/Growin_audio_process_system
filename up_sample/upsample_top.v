module upsample_top (
    input clk,
    input CIC_CLK,
    input reset_n,
    input wire signed [31:0] audio_in,  // 左声道输入
    output reg signed [31:0] audio_up_out // 左声道升采样输出
);

parameter DATA_WIDTH = 16; // 数据宽度

    // 升采样模块的实例化
    wire signed[15:0] upsampled_left;  // 左声道升采样输出
    wire signed[15:0] upsampled_right; // 右声道升采样输出

     wire signed [DATA_WIDTH-1:0] comb_out_left;
     wire signed [DATA_WIDTH-1:0] comb_out_right;
     wire signed [DATA_WIDTH-1:0] interpolation_out_left;
     wire signed [DATA_WIDTH-1:0] interpolation_out_right;   
//     左声道升采样
//    (* keep = "true" *) upsample #(
//        .UP_FACTOR(8) // 设置升采样因子为 8
//    ) upsample_left (
//        .clk(clk),
//        .rst_n(reset_n),
//        .audio_in(audio_in[31:16]),   // 左声道输入
//        .valid_in(1'b1),            // 输入有效信号
//        .audio_out(upsampled_left),     // 升采样后的左声道输出
//        .valid_out(valid_left_out)      // 左声道有效信号
//    );

    // 右声道升采样
//    upsample #(
//        .UP_FACTOR(8) // 设置升采样因子为 8
//    ) upsample_right (
//        .clk(clk),
//        .rst_n(reset_n),
//        .audio_in(audio_in[15:0]),  // 右声道输入
//        .valid_in(1'b1),          // 输入有效信号
//        .audio_out(upsampled_right),  // 升采样后的右声道输出
//        .valid_out(valid_right_out)   // 右声道有效信号
//    );
clc left (
    .clk_in(clk),                       // 输入数据时钟
    .clk_out(CIC_CLK),                      // 输出数据时钟（32 倍于 clk_in）
    .reset(!reset_n),                        // 复位信号
    .data_in(audio_in[31:16]),       // 输入数据
    .data_out(upsampled_left), // 输出数据
    .comb_out(comb_out_left), // 梳状滤波器输出
    .interpolation_out(interpolation_out_left) // 插值输出
);

clc right (
    .clk_in(clk),                       // 输入数据时钟
    .clk_out(CIC_CLK),                      // 输出数据时钟（32 倍于 clk_in）
    .reset(!reset_n),                        // 复位信号
    .data_in(audio_in[15:0]),       // 输入数据
    .data_out(upsampled_right), // 输出数据
    .comb_out(comb_out_right), // 梳状滤波器输出
    .interpolation_out(interpolation_out_right) // 插值输出
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            audio_up_out <= 0;
        end else begin     
            audio_up_out <= {upsampled_left, upsampled_right};
        end
    end  

endmodule