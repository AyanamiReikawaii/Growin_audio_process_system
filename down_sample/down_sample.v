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
    input [15:0]down_sample_parameter,
    output reg valid_out // 输出数据有效信号
);

    reg [31:0] count; // 计数器，用于控制输出速率
    wire [31:0] down_sample_count;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            audio_out <= 0;
        end 
        else 
        if (count == down_sample_count) begin
            audio_out <= audio_in;
        end
    end
    

    always@(posedge clk or negedge reset_n) begin
    if (!reset_n)
            count <= 0;
    else if(count > down_sample_count)begin              
            count <= 0; // 重置计数器      
    end
    else 
            count <= count + 32'd1;
    end

    multiplier Umult6 (
        .clk(clk),
        .rst(reset_n),
        .X (down_sample_parameter),
        .Y (16'd2000),
        .product (down_sample_count)  // 32位乘法结果
    );

endmodule