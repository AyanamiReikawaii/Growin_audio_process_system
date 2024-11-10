 module audio_lookback(
    input clk,                    
    input reset_n,                                   
    inout iic_0_scl,              
    inout iic_0_sda,   
    output led,
     

    input I2S_ADCDAT,
    input I2S_ADCLRC,
    input I2S_BCLK,
    output I2S_DACDAT,
    input I2S_DACLRC,
    output I2S_MCLK,

    input uart_rx,
    output led0,  //LED指示灿
    output led1,
    output led2
);
    /*均衡器增益参数*/
     parameter yiwei_1_100_1k =  16'd5;
     parameter yiwei_2_100_1k =  16'd5; 

     parameter yiwei_1_1k_3k =  16'd5;
     parameter yiwei_2_1k_3k =  16'd5; 

     parameter yiwei_1_3k_5k =  16'd5;
     parameter yiwei_2_3k_5k =  16'd5; 

     parameter yiwei_1_5k_8k =  16'd5;
     parameter yiwei_2_5k_8k =  16'd5; 

     parameter yiwei_1_10k_20k =  16'd5;
     parameter yiwei_2_10k_20k =  16'd5; 


    /*其他参数*/
    parameter DATA_WIDTH = 32;   
    parameter delay_dot_1  = 4000 ;
    parameter delay_dot_2  = 8000 ;
    parameter EN_INITIAL = 8'd0;
    parameter EN_FILTER = 8'd1;
    parameter EN_ECHO = 8'd2;
    parameter EN_REMIX = 8'd3;
    parameter EN_UP = 8'd4;
    parameter EN_DOWN = 8'd5;

    parameter EN_FILTER_0 = 8'd10;
    parameter EN_FILTER_1 = 8'd11;
    parameter EN_FILTER_2 = 8'd12;
    parameter EN_FILTER_3 = 8'd13;
    parameter EN_FILTER_4 = 8'd14;

    parameter EN_REMIX_S = 8'd20;
    parameter EN_REMIX_M = 8'd21;

    parameter EN_ECHO_0 = 8'd30;
    parameter EN_ECHO_1 = 8'd31;
    parameter EN_ECHO_2 = 8'd32;

    wire  MUL_CLK;
    wire CLC_IN;
    wire CLC_out;
    /*PLL模块*/
    Gowin_PLL Gowin_PLL(
        .clkout0(I2S_MCLK), //output clkout0
        .clkout1(MUL_CLK), //output clkout1 40M
        .clkout2(CLC_out), //output clkout2
        .clkin(clk) //input clkin
    );

    /*分频器模块*/
    wire freq_40k;  

    freq_div40k #(
       .CNT_MAX (1000)
    )freq_div40k1
    (
        .clk(MUL_CLK),
        .rst_n(reset_n),
        .freq_40k(freq_40k)
    );

    freq_div40k #(
       .CNT_MAX (32)
    )freq_div40k2
    (
        .clk(CLC_out),
        .rst_n(reset_n),
        .freq_40k(CLC_IN)
    );

    wire Init_Done;
    WM8960_Init WM8960_Init(
        .Clk(clk),
        .Rst_n(reset_n),
        .I2C_Init_Done(Init_Done),
        .i2c_sclk(iic_0_scl),
        .i2c_sdat(iic_0_sda)
    );
    
    assign led = Init_Done;

    reg adcfifo_read;
    wire [DATA_WIDTH - 1:0] adcfifo_readdata;
    wire adcfifo_empty;

    reg dacfifo_write;
    reg [DATA_WIDTH - 1:0] dacfifo_writedata; // 声明为 reg 类型
    wire dacfifo_full;

    // 升采样模块输出
    wire signed [DATA_WIDTH - 1:0] audio_up_out;  
    wire valid_up_out;  
    //  wire valid_delay_out;

    wire [DATA_WIDTH - 1:0] delay_in; 
    wire [DATA_WIDTH - 1:0] delay_out;

    reg [DATA_WIDTH - 1:0] dtx_out;
    // 二倍速模块输出
    wire [DATA_WIDTH - 1:0] down_sample_audio;
    wire valid_out; // 输出数据有效信号
    wire [DATA_WIDTH - 1:0] dacdadte_audio;

    wire [DATA_WIDTH - 1:0] audio_lowpass_out;
    wire [DATA_WIDTH - 1:0] mix_filter_32bits_audio;

    // 读取 ADC FIFO 数据
    always @ (posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            adcfifo_read <= 1'b0;
        end else if (~adcfifo_empty) begin
            adcfifo_read <= 1'b1; // Read from ADC FIFO
        end else begin
            adcfifo_read <= 1'b0;
        end
    end


    // 写入 DAC FIFO 数据
    always @ (posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            dacfifo_write <= 1'd0;
        end else if (~dacfifo_full ) begin //删掉了valid_out
            dacfifo_write <= 1'd1;
           // dacfifo_writedata <= dtx_out; 
            dacfifo_writedata <= dtx_out;
        end else begin
            dacfifo_write <= 1'd0;
        end
    end

    // I2S RX 模块
    i2s_rx 
    #(
        .DATA_WIDTH(DATA_WIDTH) 
    ) i2s_rx (
        .reset_n(reset_n),
        .bclk(I2S_BCLK),
        .adclrc(I2S_ADCLRC),
        .adcdat(I2S_ADCDAT),
        .adcfifo_rdclk(clk),
        .adcfifo_read(adcfifo_read),
        .adcfifo_empty(adcfifo_empty),
        .adcfifo_readdata(adcfifo_readdata)
    );

    // I2S TX 模块
    i2s_tx
    #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i2s_tx (
        .reset_n(reset_n),
        .dacfifo_wrclk(clk),
        .dacfifo_wren(dacfifo_write),
        .dacfifo_wrdata(dacfifo_writedata),
        .dacfifo_full(dacfifo_full),
        .bclk(I2S_BCLK),
        .daclrc(I2S_DACLRC),
        .dacdat(I2S_DACDAT)
    );

//////*降频模块*//////////////////////////////////////////////////////////////////////////////  
    reg [15:0] down_sample_parameter;
    down_sample
    #(
        .DATA_WIDTH(DATA_WIDTH)
    ) down_sample_inst (
        .clk(clk),
        .reset_n(reset_n),
        .audio_in(adcfifo_readdata), // 连接到 ADC FIFO 读取的数据
        .audio_out(down_sample_audio), // 二倍速输出
        .valid_in(1'b1), // 输入数据‘有效信号
        .valid_out(valid_out), // 输出数据有效信号
        .down_sample_parameter(down_sample_parameter)
    );

//////*回声、混响模块*//////////////////////////////////////////////////////////////////////////////  

    wire [31:0] number;
    reg [1:0] delay_state;

     delay_fifo 
    #(
         .delay_dot_1(delay_dot_1) ,
         .delay_dot_2(delay_dot_2)   
    )
     delay_fifo(
        .clk(freq_40k),
        .rst_n(reset_n),          // 低电平有效复位
        .delay_in(audio_up_out), // 输入音频信号
        .valid_delay_in(1'b1),       // 输入有效信号
        .count(delay_state),
        .delay_out(delay_out) // 输出音频信号
      //  .valid_delay_out(valid_delay_out)   // 输出有效信号
    );


//////*升采样模块*////////////////////////////////////////////////////////////////////////////// 
 
    upsample_top upsample_top(
         .clk(CLC_IN),
         .CIC_CLK(CLC_out),
         .reset_n(reset_n),
         .audio_in(adcfifo_readdata),  
         .audio_up_out(audio_up_out)                  // 右声道升采样输出
    );



//////*滤波器综合模块*//////////////////////////////////////////////////////////////////////////////  

      reg  [15:0]  filter_gain_100_1k_1;
      reg  [15:0]  filter_gain_100_1k_2;
      reg  [15:0]  filter_gain_1k_3k_1;
      reg  [15:0]  filter_gain_1k_3k_2;
      reg  [15:0]  filter_gain_3k_5k_1;
      reg  [15:0]  filter_gain_3k_5k_2;
      reg  [15:0]  filter_gain_5k_8k_1;
      reg  [15:0]  filter_gain_5k_8k_2;
      reg  [15:0]  filter_gain_6k_15k_1;
      reg  [15:0]  filter_gain_6k_15k_2;

    filter_all   upsample_32bits1( 
        .clk(clk),
        .reset(reset_n),
        .filter_in(adcfifo_readdata), // 连接到 ADC FIFO 读取的数据
        .filter_out_all(mix_filter_32bits_audio), // 二倍速输出
        .clk_enable(1'b1), // 输入数据有效信号
        .filter_gain_100_1k_1(filter_gain_100_1k_1),
        .filter_gain_100_1k_2(filter_gain_100_1k_2),
        .filter_gain_1k_3k_1(filter_gain_1k_3k_1),
        .filter_gain_1k_3k_2(filter_gain_1k_3k_2),
        .filter_gain_3k_5k_1(filter_gain_3k_5k_1),
        .filter_gain_3k_5k_2(filter_gain_3k_5k_2),
        .filter_gain_5k_8k_1(filter_gain_5k_8k_1),
        .filter_gain_5k_8k_2(filter_gain_5k_8k_2),
        .filter_gain_6k_15k_1(filter_gain_6k_15k_1),
        .filter_gain_6k_15k_2(filter_gain_6k_15k_2)
    );

//////*输出通道选择模块*//////////////////////////////////////////////////////////////////////////////  

    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)    
            dtx_out <= 0;
        else if(check_ok==EN_INITIAL)begin
            dtx_out <= adcfifo_readdata;
            filter_gain_100_1k_1 <= 8'd4;
            filter_gain_100_1k_2 <= 8'd5;
            filter_gain_1k_3k_1 <= 8'd4;
            filter_gain_1k_3k_2 <= 8'd5;
            filter_gain_3k_5k_1 <= 8'd4;
            filter_gain_3k_5k_2 <= 8'd5;
            filter_gain_5k_8k_1 <= 8'd4;
            filter_gain_5k_8k_2 <= 8'd5;
            filter_gain_6k_15k_1 <= 8'd4;
            filter_gain_6k_15k_2 <= 8'd5;
        end
        else if(check_ok==EN_FILTER||check_ok==EN_FILTER_0||check_ok==EN_FILTER_1||check_ok==EN_FILTER_2||check_ok==EN_FILTER_3)begin  
            dtx_out <= mix_filter_32bits_audio;
        end
        else if(check_ok==EN_FILTER_4)begin  
            dtx_out <= mix_filter_32bits_audio;
            filter_gain_100_1k_1 <= number[2:0];
            filter_gain_100_1k_2 <= number[2:0];
            filter_gain_1k_3k_1 <= number[5:3];
            filter_gain_1k_3k_2 <= number[5:3];
            filter_gain_3k_5k_1 <= number[8:6];
            filter_gain_3k_5k_2 <= number[8:6];
            filter_gain_5k_8k_1 <= number[11:9];
            filter_gain_5k_8k_2 <= number[11:9];
            filter_gain_6k_15k_1 <= number[14:12];
            filter_gain_6k_15k_2 <= number[14:12];
        end
        else if(check_ok==EN_ECHO)begin  
            dtx_out <= delay_out;
            delay_state <= number[1:0];
        end
        else if(check_ok==EN_REMIX||check_ok==EN_REMIX_M||check_ok==EN_REMIX_S)  begin
            dtx_out <= delay_out;
            delay_state <= number[1:0];
        end
        else if(check_ok==EN_UP)  
            dtx_out <= audio_up_out;
        else if(check_ok==EN_DOWN) begin
            dtx_out <= down_sample_audio;
            down_sample_parameter <= number[15:0];
        end
        else 
        dtx_out <= adcfifo_readdata;
    end

    reg led0;
    reg led1;
    reg led2;
	
	wire [7:0]data_uart;        //串口接收数据,作为字符数据输入	
	wire data_valid;  //1byte数据接收完成标志

	wire [7:0]check_ok;    //字符串检测成功标诿

//////*串口通信模块*//////////////////////////////////////////////////////////////////////////////  

    uart_byte_rx uart_byte_rx(
		.clk(clk),
		.reset_n(reset_n),

		.baud_set(3'd0),
		.uart_rx(uart_rx),
		
		.data_byte(data_uart),
		.rx_done(data_valid)
	);
 
//////*状态机模块*//////////////////////////////////////////////////////////////////////////////  

	fsm_hello#(
        .EN_INITIAL(EN_INITIAL) ,
        .EN_FILTER(EN_FILTER) ,
        .EN_ECHO(EN_ECHO) ,
        .EN_REMIX(EN_REMIX) ,
        .EN_UP(EN_UP),
        .EN_DOWN(EN_DOWN),
        .EN_FILTER_0(EN_FILTER_0),
        .EN_FILTER_1(EN_FILTER_1),
        .EN_FILTER_2(EN_FILTER_2),
        .EN_FILTER_3(EN_FILTER_3),
        .EN_FILTER_4(EN_FILTER_4),
        .EN_REMIX_S(EN_REMIX_S),
        .EN_REMIX_M(EN_REMIX_M)
) 
    fsm_hello(
		.clk(clk),
		.reset_n(reset_n),

		.data_valid(data_valid),
		.data_in(data_uart),

		.check_ok(check_ok),
        .number(number)
	);

//////*灯模块*//////////////////////////////////////////////////////////////////////////////  

	always@(posedge clk or negedge reset_n)begin
	if(!reset_n)begin
		led0 <= 1'b1;
		led1 <= 1'b1;
		led2 <= 1'b1;
    end
	else if(check_ok == EN_INITIAL)begin
		led0 <= 1'b1;
		led1 <= 1'b1;
		led2 <= 1'b1;
    end
	else if(check_ok == EN_FILTER)begin
		led0 <= 1'b0;
		led1 <= 1'b1;
		led2 <= 1'b1;
    end
	else if(check_ok == EN_ECHO)begin
		led0 <= 1'b1;
		led1 <= 1'b0;
		led2 <= 1'b1;
    end
	else if(check_ok == EN_REMIX)begin
		led0 <= 1'b0;
		led1 <= 1'b0;
		led2 <= 1'b1;
    end
	else begin
		led0 <= 1'b0;
		led1 <= 1'b0;
		led2 <= 1'b0;
    end
    end
 
endmodule 