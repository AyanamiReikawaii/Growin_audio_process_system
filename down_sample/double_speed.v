module down_sample
#(
    parameter DATA_WIDTH        = 32    //left+right = 16 +16 =32 
)
(
    input clk,
    input reset_n,
    input [DATA_WIDTH-1:0] audio_in,
    output reg [DATA_WIDTH-1:0] audio_out,
    input valid_in, // 输入数据有效信号
    output reg valid_out // 输出数据有效信号
);

    reg [20:0] count; // 计数器，用于控制输出速率

    always @(posedge clk      or negedge reset_n) begin
        if (!reset_n) begin
            count <= 0;
            valid_out <= 0;
            audio_out <= 0;
        end else begin
            if (valid_in) begin
                count <= count + 1;
                // 每两次输入有效时输出一次
                if (count == 20000) begin
                    audio_out <= audio_in; // 输出数据
                    valid_out <= 1; // 数据有效
                    count <= 0; // 重置计数器
                end else begin
                    valid_out <= 0; // 当前输出无效
                end
            end
        end
    end
endmodule