module upsample(
    input clk,
    input rst_n,          // 低电平有效复位
    input [15:0] audio_in, // 输入音频信号
    input valid_in,       // 输入有效信号
    output reg [15:0] audio_out, // 输出音频信号
    output reg valid_out   // 输出有效信号
);

parameter UP_FACTOR = 8; // 升采样因子为 8

// 计数器，用于跟踪插入零
reg [2:0] count; // 3位计数器，范围 0-7
reg [15:0] audio_sample; // 存储有效音频样本

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 0;
        audio_out <= 0;
        valid_out <= 0;
    end else begin
        if (valid_in) begin
            audio_sample <= audio_in; // 存储有效输入样本
            count <= 0; // 重置计数器
            valid_out <= 1; // 输出有效信号
            audio_out <= audio_sample; // 输出有效样本
        end else begin
            if (count < UP_FACTOR - 1) begin
                count <= count + 1; // 增加计数
                valid_out <= 0; // 输出无效信号
                audio_out <= 0; // 输出零值（插值）
            end else begin
                count <= 0; // 重置计数器
                valid_out <= 1; // 输出有效信号
                audio_out <= audio_sample; // 输出有效样本
            end
        end
    end
end

endmodule