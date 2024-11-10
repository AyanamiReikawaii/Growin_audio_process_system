module Echo(
    input clk,
    input rst,  // 低电平有效复位
    input  [15:0] audio_in,
    input in_able,
    output reg  [15:0] audio_out
);

parameter DELAY = 100; // 根据延迟时间设置
reg  [15:0] delay_line[0:DELAY-1];
reg [15:0] write_ptr = 0;
reg [15:0] read_ptr = 0;
reg [15:0]  count;
integer i;

always@(posedge clk or negedge rst) begin
    if (!rst)     count <= 16'd0; 
    else if(count==16'd10)  count<=16'd0;
    else  count <=count+16'd1;
    end
   
always@(posedge clk or negedge rst) begin
    if (!rst)     write_ptr <= 16'd50; 
    else if(write_ptr==16'd100)  write_ptr<=16'd0;
    else if(count==16'd10) write_ptr <=write_ptr+16'd1;
    end  

always@(posedge clk or negedge rst) begin
    if (!rst)     read_ptr <= 16'd0; 
    else if(read_ptr==16'd100)  read_ptr<=16'd0;
    else if(count==16'd10)  read_ptr <=read_ptr+16'd1;
    end  


always @(posedge clk or negedge rst) begin
    if (!rst) begin  // 低电平复位
        audio_out <= 0; // 可选，清零输出
        end
    else 
    if(in_able)begin
        // 写入当前音频样本
//    if(count==16'd10000) begin
//        delay_line[write_ptr] <= audio_in;
//        write_ptr <= (write_ptr + 1) % DELAY;

         
//        audio_out <= audio_in + (delay_line[read_ptr] >> 5); // 控制混合比例
//        audio_out <= (audio_in) +(delay_line[read_ptr] <<2); // 控制混合比例
//        read_ptr <= (read_ptr + 1) % DELAY;
//     end
        if(count==16'd10) begin
            delay_line[write_ptr] <= audio_in;
        end
        else     
            audio_out <=  audio_in + delay_line[read_ptr]; // 控制混合比例
            //audio_out <=  audio_in; // 控制混合比例
            //audio_out <=  delay_line[read_ptr]; // 控制混合比例
            
           
    end
end


endmodule


module EchoProcessor(
    input clk,
    input rst,  // 低电平有效复位
    input in_able,
    input  [31:0] audio_in,
    output reg  [31:0] audio_out
);

    // 定义音频处理模块实例
    wire  [15:0] upper_out;
    wire  [15:0] lower_out;

    // 实例化上半部分和下半部分的回声处理模块
    Echo upper_echo (
        .clk(clk),
        .rst(rst),
        .audio_in(audio_in[31:16]), // 上16位输入
        .in_able(in_able),
        .audio_out(upper_out)        // 上16位输出
    );

    Echo lower_echo (
        .clk(clk),
        .rst(rst),
        .audio_in(audio_in[15:0]), // 下16位输入
        .in_able(in_able),
        .audio_out(lower_out)        // 下16位输出
    );

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            audio_out <= 0; // 可选，清零输出
        end else begin
            // 合并处理后的结果
            if(in_able)
            audio_out <= {upper_out, lower_out}; // 组合为32位输出
            else
             audio_out <= audio_in;
        end
    end
endmodule