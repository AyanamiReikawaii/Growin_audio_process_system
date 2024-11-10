module delay_fifo
#(
    parameter delay_dot_1  = 4000 ,
    parameter delay_dot_2  = 8000   
)
(
    input clk,
    input rst_n,          // 低电平有效复位
    input [31:0] delay_in, // 输入音频信号
    input valid_delay_in,       // 输入有效信号
    input   [1:0] count,
    output reg [31:0] delay_out // 输出音频信号
 //   output reg valid_delay_out   // 输出有效信号
);


wire RdEn;
wire RdEn_1;

//wire Empty;
//wire Empty_1;

wire Full;
wire Full_1;
wire Full_2;

//wire [12:0] Wnum;
wire [12:0] Rnum;
//wire [12:0] Wnum_1;
wire [12:0] Rnum_1;


wire [31:0] delay_out_temp;
wire [31:0] delay_out_temp_1;
wire [31:0] delay_out_temp_2;




assign  RdEn  = (Rnum  >delay_dot_1)?1:0;
assign  RdEn_1= (Rnum_1>delay_dot_2)?1:0;


//reg [31:0] delay_out_reg;

//assign RdEn=Rnable;

//always @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            delay_out_reg<=0;
//        end else begin
//           delay_out_reg <= delay_out_temp;
//            end
//    end

always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delay_out<=0;
        end else begin
           case(count)
            2'b00: delay_out <= (delay_in<<1) + delay_out_temp_1;//remix
            2'b01: delay_out <= (delay_in << 2 )+ delay_out_temp_1 + delay_out_temp_2; //remix_M
            2'b10: delay_out <= (delay_in << 2 )+ (delay_out_temp <<1 ) + delay_out_temp_1; //remix_S
            2'b11: delay_out <= (delay_in)+ delay_out_temp_1; //echo
           endcase
            end
    end


	fifo_delay_cx  fifodelay1(
		.Data(delay_in), //input [31:0] Data
		.Reset(~rst_n), //input Reset
		.WrClk(clk), //input WrClk
		.RdClk(clk), //input RdClk
		.WrEn(1'b1), //input WrEn
		.RdEn(RdEn), //input RdEn
		.Wnum(), //output [13:0] Wnum
		.Rnum(Rnum), //output [13:0] Rnum
		.Almost_Empty(), //output Almost_Empty
		.Almost_Full(), //output Almost_Full
		.Q(delay_out_temp), //output [31:0] Q
		.Empty(), //output Empty
		.Full(Full) //output Full
	);
   
   	fifo_delay_cx  fifodelay2(
		.Data(delay_in), //input [31:0] Data
		.Reset(~rst_n), //input Reset
		.WrClk(clk), //input WrClk
		.RdClk(clk), //input RdClk
		.WrEn(1'b1), //input WrEn
		.RdEn(RdEn_1), //input RdEn
		.Wnum(), //output [13:0] Wnum
		.Rnum(Rnum_1), //output [13:0] Rnum
		.Almost_Empty(), //output Almost_Empty
		.Almost_Full(), //output Almost_Full
		.Q(delay_out_temp_1), //output [31:0] Q
		.Empty(), //output Empty
		.Full(Full_1) //output Full
	);

     	fifo_delay_cx  fifodelay3(
		.Data(delay_out_temp), //input [31:0] Data
		.Reset(~rst_n), //input Reset
		.WrClk(clk), //input WrClk
		.RdClk(clk), //input RdClk
		.WrEn(1'b1), //input WrEn
		.RdEn(Full_2), //input RdEn
		.Wnum(), //output [13:0] Wnum
		.Rnum(), //output [13:0] Rnum
		.Almost_Empty(), //output Almost_Empty
		.Almost_Full(), //output Almost_Full
		.Q(delay_out_temp_2), //output [31:0] Q
		.Empty(), //output Empty
		.Full(Full_2) //output Full
	);



endmodule
