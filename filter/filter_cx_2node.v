
module filter_cx_2node 
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
	input   	rst,
	input		clk,
	input	 signed [15:0]	din,
	output   signed [15:0]	dout,
    input  [15:0] yiwei_1 ,
    input  [15:0] yiwei_2 
	);
	
	wire signed [33:0] Xout_1;
	wire signed [15:0] Yin_1;
	wire signed [33:0] Yout_1;
    wire signed [15:0]	dout_node;

	 Zero_2node 
    #(
     .a1(a1), 
     .a2(a2),
     .a3(a3)
    )U0(
		.rst (rst),
		.clk (clk),
		.Xin (din),
		.Xout (Xout_1)
		);

    Pole_2node  
    #(
     .b1(b1), 
     .b2(b2),
     .b3(b3)
    )U1(
		.rst (rst),
		.clk (clk),
		.Yin (Yin_1),
		.Yout (Yout_1)
		);
 
    wire signed [33:0] Ysum_1;
    assign Ysum_1 = Xout_1 - Yout_1;
	wire signed [33:0] Ydiv_1;
	//assign Ydiv_1 = {{14{Ysum_1[34]}},Ysum_1[34:14]};
	assign Ydiv_1 = Ysum_1 >>> b1;
	//直接对结果进行截尾
	assign Yin_1 = ((!rst) ? 16'd0 : Ydiv_1[15:0]);
	assign dout_node = Yin_1<<yiwei_1;

    wire signed [33:0] Xout_2;
    wire signed [15:0] Yin_2;
	wire signed [33:0] Yout_2;

    Zero_2node 
    #(
     .a1(a4), 
     .a2(a5),
     .a3(a6)
    )U2(
		.rst (rst),
		.clk (clk),
		.Xin (dout_node),
		.Xout (Xout_2)
		);

    Pole_2node  
    #(
     .b1(b4), 
     .b2(b5),
     .b3(b6)
    )U3(
		.rst (rst),
		.clk (clk),
		.Yin (Yin_2),
		.Yout (Yout_2)
		);

    wire signed [33:0] Ysum_2;
    assign Ysum_2 = Xout_2 - Yout_2;
	wire signed [33:0] Ydiv_2;
	//assign Ydiv_2 = {{14{Ysum_2[34]}},Ysum_2[34:14]};
	assign Ydiv_2 = Ysum_2 >>> b4;  //直接对结果进行截尾
	assign Yin_2 = ((!rst) ? 16'd0 : Ydiv_2[15:0]);
	assign dout = Yin_2<<yiwei_2;

endmodule




module Zero_2node
#(
     parameter a1 =  16'd0, 
     parameter a2 =  16'd0,
     parameter a3 =  16'd0
)
(
    input               rst,  
    input               clk,
    input   signed [15:0] Xin,  // 输入信号
    output  signed [33:0] Xout   // 输出信号宽度为34位
);

//-------------------------------------------------------
//   将数据移位寄存
//-------------------------------------------------------
    reg signed [15:0] Xin_Reg[2:0];  // 存储历史输入
   // reg [1:0] i, j; 
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin 
         Xin_Reg[0] <= 16'd0;  // 复位
         Xin_Reg[1] <= 16'd0;  // 复位
         Xin_Reg[2] <= 16'd0;  // 复位
        end else begin
        if(Xin_Reg[0]!=Xin)begin
         Xin_Reg[2] <= Xin_Reg[1];  // 移位
         Xin_Reg[1] <= Xin_Reg[0];  // 移位   
         Xin_Reg[0] <= Xin;  // 当前输入
        end
        end
    end

//-------------------------------------------------------
//   系数定义
//-------------------------------------------------------		
   // wire signed [15:0] coe[1:0];       
    wire signed [31:0] Mult_Reg[2:0];   // 乘法器结果，32位

    // 系数定义
   // assign coe[0] =  16'd4096;  // a1 系数
   // assign coe[1] =  -16'd8192;  // a2 系数（注意应为负）

//-------------------------------------------------------
//   计算乘法
//------------------------------------------------------	
    multiplier Umult0 (
        .clk(clk),
        .rst(rst),
        .X (Xin_Reg[0]),
        .Y (a1),
        .product (Mult_Reg[0])  // 32位乘法结果
    );	
    multiplier Umult1 (
        .clk(clk),
        .rst(rst),
        .X (Xin_Reg[1]),
        .Y (a2),
        .product (Mult_Reg[1])  // 32位乘法结果
    );
    multiplier Umult2 (
        .clk(clk),
        .rst(rst),
        .X (Xin_Reg[2]),
        .Y (a3),
        .product (Mult_Reg[2])  // 32位乘法结果
    );

//-------------------------------------------------------
//   输出计算，使用符号扩展
//-------------------------------------------------------	
    assign Xout = {{2{Mult_Reg[0][31]}}, Mult_Reg[0]} +  // 符号扩展
                   {{2{Mult_Reg[1][31]}}, Mult_Reg[1]} +  // 符号扩展
                   {{2{Mult_Reg[2][31]}},  Mult_Reg[2]};  // 符号扩展


endmodule



module Pole_2node
#(
     parameter b1 =  16'd0, 
     parameter b2 =  16'd0,
     parameter b3 =  16'd0
)(
    input               rst,  
    input               clk,
    input   signed [15:0] Yin,  // 输入信号
    output  signed [33:0] Yout   // 输出信号宽度为34位
);

//-------------------------------------------------------
//   将数据移位寄存
//-------------------------------------------------------
    reg signed [15:0] Yin_Reg[2:0];  // 存储历史输入
    //reg [1:0] i, j; 
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin 
         Yin_Reg[0] <= 16'd0;  // 复位
         Yin_Reg[1] <= 16'd0;  // 复位
         Yin_Reg[2] <= 16'd0;  // 复位
        end else begin
        if(Yin_Reg[0]!=Yin)begin
         Yin_Reg[2] <= Yin_Reg[1];  // 移位
         Yin_Reg[1] <= Yin_Reg[0];  // 移位   
         Yin_Reg[0] <= Yin;  // 当前输入
        end
        end
    end


//-------------------------------------------------------
//   系数定义
//-------------------------------------------------------		
   // wire signed [15:0] coe[1:0];       
    wire signed [31:0] Mult_Reg[1:0];   // 乘法器结果，32位

    // 系数定义
   // assign coe[0] =  16'd4096;  // a1 系数
   // assign coe[1] =  -16'd8192;  // a2 系数（注意应为负）

//-------------------------------------------------------
//   计算乘法
//------------------------------------------------------	
    multiplier Umult0 (
        .clk(clk),
        .rst(rst),
        .X (Yin_Reg[1]),
        .Y (b2),
        .product (Mult_Reg[0])  // 32位乘法结果
    );	
    multiplier Umult1 (
        .clk(clk),
        .rst(rst),
        .X (Yin_Reg[2]),
        .Y (b3),
        .product (Mult_Reg[1])  // 32位乘法结果
    );

//-------------------------------------------------------
//   输出计算，使用符号扩展
//-------------------------------------------------------	

    assign Yout = {{2{Mult_Reg[0][31]}}, Mult_Reg[0]} +  // 符号扩展
                   {{2{Mult_Reg[1][31]}}, Mult_Reg[1]};  // 符号扩展
  
                 

endmodule