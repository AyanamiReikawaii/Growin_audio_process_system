module mix_filter_32bits
#(  
     parameter a1 =  16'd0,
     parameter a2 =  16'd0,
     parameter a3 =  16'd0,
     parameter a4 =  16'd0,
     parameter a5 =  16'd0,   
     parameter a6 =  16'd0,
     
     parameter b1 =  16'd0,    //2^n
     parameter b2 =  16'd0,
     parameter b3 =  16'd0,     
     parameter b4 =  16'd0,     //2^n
     parameter b5 =  16'd0,
     parameter b6 =  16'd0
)(
        input clk,
        input reset_n,
        input [31:0] audio_in, // 32位输入
        output reg [31:0] audio_out, // 32位输出
        input valid_in, // 输入数据有效信号
        output reg valid_out, // 输出数据有效信号
        input  [15:0] yiwei_1,
        input  [15:0] yiwei_2 
);

    // 拆分左声道和右声道
    wire signed [15:0] left_channel = audio_in[31:16]/* synthesis syn_keep=1 */;
    wire signed [15:0] right_channel = audio_in[15:0]/* synthesis syn_keep=1 */;

    wire signed [15:0] filtered_left/* synthesis syn_keep=1 */;
    wire signed [15:0] filtered_right/* synthesis syn_keep=1 */;

 filter_cx_2node
 #(
     .a1(a1), 
     .a2(a2),
     .a3(a3),
     .a4(a4),
     .a5(a5),
     .a6(a6),  
     .b1(b1), 
     .b2(b2),
     .b3(b3),
     .b4(b4),
     .b5(b5),
     .b6(b6)
    )
 filter_left_0 (
        .clk(clk),
        .rst(reset_n),
        .din(left_channel),
        .dout(filtered_left),
     .yiwei_1(yiwei_1),
     .yiwei_2(yiwei_2)
    ); 

//    filter_cx_2node 
//#(
//     .a1(a1), 
//     .a2(a2),
//     .a3(a3),
//     .a4(a4),
//     .a5(a5),
//     .a6(a6),  
//     .b1(b1), 
//     .b2(b2),
//     .b3(b3),
//     .b4(b4),
//     .b5(b5),
//     .b6(b6)
//    )
// filter_right_0(
//        .clk(clk),
//        .rst(reset_n),
//        .din(right_channel),
//        .dout(filtered_right),
//     .yiwei_1(yiwei_1),
//     .yiwei_2(yiwei_2) 
//    );


always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            valid_out <= 0;
            audio_out <= 0;
        end else begin
            if (valid_in) begin
                if (1) begin
                   audio_out <= {filtered_left, filtered_left}; // 输出数据
                    valid_out <= 1; // 数据有效
                end else begin
                    valid_out <= 0; // 当前输出无效
                end
            end
        end
        
        
end  


endmodule

