//////////////////////////////////////////////////////////////////////////////////
// Company: 武汉芯路恒科技有限公司
// Engineer: 小梅哥团队
// Web: www.corecourse.cn
// 
// Create Date: 2020/07/20 00:00:00
// Design Name: 
// Module Name: fsm_hello
// Project Name: 
// Description: 实现字符串“hello”检测，每检测成功一次产生一个时钟周期脉冲check_ok
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fsm_hello#(
    parameter EN_INITIAL = 8'd0,
    parameter EN_FILTER = 8'd1,
    parameter EN_ECHO = 8'd2,
    parameter EN_REMIX = 8'd3,
    parameter EN_UP = 8'd4,
    parameter EN_DOWN = 8'd5,

    parameter EN_FILTER_0 = 8'd10,
    parameter EN_FILTER_1 = 8'd11,
    parameter EN_FILTER_2 = 8'd12,
    parameter EN_FILTER_3 = 8'd13,
    parameter EN_FILTER_4 = 8'd14,

    parameter EN_REMIX_S = 8'd20,
    parameter EN_REMIX_M = 8'd21
) 
(
	clk,
	reset_n,

	data_valid,
	data_in,

	check_ok,
    number
);

	input clk;          //模块全局时钟输入，50M
	input reset_n;         //复位信号输入，低有效

	
	input data_valid; //输入字符数据有效标识
	input [7:0]data_in;    //字符数据输入
	
	output [7:0] check_ok;   //字符串检测成功标识
    output [31:0] number;

	reg [7:0]check_ok;
    reg [31:0]number;
	reg [15:0]down_number;
	localparam
        WAIT= 5'd0,
		CHECK_filter= 5'd1,
		CHECK_echo= 5'd2,
		CHECK_remix= 5'd3,
        CHECK_up= 5'd4,
        CHECK_down= 5'd5,
		
        CHECK_filter_0= 5'd10,
		CHECK_filter_1= 5'd11,
        CHECK_filter_2= 5'd12,
        CHECK_filter_3= 5'd13,
        CHECK_filter_4= 5'd14,

		CHECK_remix_S= 5'd20,
        CHECK_remix_M= 5'd21;
	

    reg [4:0]state;
	
	always@(posedge clk or negedge reset_n)
	if(!reset_n)begin
		check_ok <= 8'b0;
		state <= WAIT;
	end
	else begin
		case(state)
			WAIT:
				begin

				check_ok <= EN_INITIAL;
                number <= 31'd0;

				if(data_valid && data_in == "f") 
				state <= CHECK_filter;
				else if(data_valid && data_in == "e") 
				state <= CHECK_echo;
                else if(data_valid && data_in == "r") 
				state <= CHECK_remix;
                else if(data_valid && data_in == "s") 
				state <= CHECK_remix_S;
                else if(data_valid && data_in == "m") 
				state <= CHECK_remix_M;
				else if(data_valid && data_in == "u") 
				state <= CHECK_up;
                else if(data_valid && data_in == "d") 
				state <= CHECK_down;
                else 
                state <= WAIT;

				end

			CHECK_filter:
			    begin

				check_ok <= EN_FILTER;
                

				if(data_valid && data_in == "b") 
				state <= WAIT;

				else if(data_valid && (data_in == "0"||data_in == "1"||data_in == "2"||data_in == "3"||data_in == "4"||data_in == "5"))begin
				state <= CHECK_filter;
                number[7:0] <= data_in - 8'd48;
                end
                else if(data_valid && data_in == "A")
                state <= CHECK_filter_0;
                else
                state <= CHECK_filter;

                end

            CHECK_filter_0:
                begin

				check_ok <= EN_FILTER_0;

				if(data_valid && data_in == "b") 
				state <= WAIT;

				else if(data_valid && (data_in == "0"||data_in == "1"||data_in == "2"||data_in == "3"||data_in == "4"||data_in == "5"))begin
				state <= CHECK_filter_0;
                number[10:3] <= data_in - 8'd48;

                end
                else if(data_valid && data_in == "B")
                state <= CHECK_filter_1;

                else
                state <= CHECK_filter_0;

                end

            CHECK_filter_1:
                begin

				check_ok <= EN_FILTER_1;

				if(data_valid && data_in == "b") 
				state <= WAIT;

				else if(data_valid && (data_in == "0"||data_in == "1"||data_in == "2"||data_in == "3"||data_in == "4"||data_in == "5"))begin
				state <= CHECK_filter_1;
                number[13:6] <= data_in - 8'd48;

                end
                else if(data_valid && data_in == "C")
                state <= CHECK_filter_2;

                else
                state <= CHECK_filter_1;

                end



            CHECK_filter_2:
                begin

				check_ok <= EN_FILTER_2;

				if(data_valid && data_in == "b") 
				state <= WAIT;

				else if(data_valid && (data_in == "0"||data_in == "1"||data_in == "2"||data_in == "3"||data_in == "4"||data_in == "5"))begin
				state <= CHECK_filter_2;
                number[16:9] <= data_in - 8'd48;
                end
                
                else if(data_valid && data_in == "D")
                state <= CHECK_filter_3;

                else
                state <= CHECK_filter_2;

                end

            CHECK_filter_3:
                begin

				check_ok <= EN_FILTER_3;

				if(data_valid && data_in == "b") 
				state <= WAIT;

				else if(data_valid && (data_in == "0"||data_in == "1"||data_in == "2"||data_in == "3"||data_in == "4"||data_in == "5"))begin
				state <= CHECK_filter_4;
                number[19:12] <= data_in - 8'd48;
                end

                else
                state <= CHECK_filter_3;
                end

            CHECK_filter_4:
                begin

				check_ok <= EN_FILTER_4;

				if(data_valid && data_in == "b") 
				state <= WAIT;
                else
                state <= CHECK_filter_4;



                end

			CHECK_remix:
                begin

				check_ok <= EN_REMIX;
                number[1:0] <= 2'b00;

				if(data_valid && data_in == "b") 
				state <= WAIT;
				else
				state <= CHECK_remix;

                end

			CHECK_remix_M:
                begin

				check_ok <= EN_REMIX_M;
                number[1:0] <= 2'b01;

				if(data_valid && data_in == "b") 
				state <= WAIT;
				else
				state <= CHECK_remix_M;

                end

			CHECK_remix_S:
                begin

				check_ok <= EN_REMIX_S;
                number[1:0] <= 2'b10;

				if(data_valid && data_in == "b") 
				state <= WAIT;
				else
				state <= CHECK_remix_S;

                end


			CHECK_up:
                begin

				check_ok <= EN_UP;

				if(data_valid && data_in == "b") 
				state <= WAIT;
				else
				state <= CHECK_up;

                end

			CHECK_down:
                begin

				check_ok <= EN_DOWN;


				if(data_valid && data_in == "b") 
				state <= WAIT;
				else if(data_valid && (data_in == "0"||data_in == "1"||data_in == "2"||data_in == "3"||data_in == "4"||data_in == "5"||data_in == "6"||data_in == "7"||data_in == "8"||data_in == "9"))begin
				state <= CHECK_down;
                number[15:0] <= data_in - 15'd48;
                end
				else
				state <= CHECK_down;

                end

            CHECK_echo:
                begin

				check_ok <= EN_ECHO;
                number[1:0] <= 2'b11;

				if(data_valid && data_in == "b") 
				state <= WAIT;
				else
				state <= CHECK_echo;

                end


				
			default:state <= WAIT;
		endcase		
	end



endmodule
