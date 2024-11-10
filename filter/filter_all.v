module filter_all
//#(
//     parameter yiwei_1_100_1k =  16'd6,
//     parameter yiwei_2_100_1k =  16'd5, 

//     parameter yiwei_1_1k_3k =  16'd6,
//     parameter yiwei_2_1k_3k =  16'd5,

//     parameter yiwei_1_3k_5k =  16'd6,
//     parameter yiwei_2_3k_5k =  16'd5, 

//     parameter yiwei_1_5k_8k =  16'd6,
//     parameter yiwei_2_5k_8k =  16'd5, 

//     parameter yiwei_1_10k_20k =  16'd6,
//     parameter yiwei_2_10k_20k =  16'd5 
//)
               (
             input   clk,
             input    clk_enable,
             input     reset,
             input signed [31:0]   filter_in,
             output  reg signed [31:0]   filter_out_all,
      input  [15:0]  filter_gain_100_1k_1,
      input  [15:0]  filter_gain_100_1k_2,
      input  [15:0]  filter_gain_1k_3k_1,
      input  [15:0]  filter_gain_1k_3k_2,
      input  [15:0]  filter_gain_3k_5k_1,
      input  [15:0]  filter_gain_3k_5k_2,
      input  [15:0]  filter_gain_5k_8k_1,
      input  [15:0]  filter_gain_5k_8k_2,
      input  [15:0]  filter_gain_6k_15k_1,
      input  [15:0]  filter_gain_6k_15k_2
                );

  wire   signed [31:0] filter_out[4:0];
  wire   signed [31:0]filter_out_a;
  assign filter_out_a=(filter_gain_100_1k_1)?filter_in:0;

/*          100-1k        */   
     parameter a1_100_1k =  16'd927 ;//X
     parameter a2_100_1k =  16'd0;
     parameter a3_100_1k =  -16'd927;     
     parameter a4_100_1k =  16'd927;
     parameter a5_100_1k =  16'd0;
     parameter a6_100_1k =  -16'd927; 
     parameter b1_100_1k =  16'd16;   //Y
     parameter b2_100_1k =  -16'd32478;
     parameter b3_100_1k =  16'd16097;
     parameter b4_100_1k =  16'd16;
     parameter b5_100_1k =  -16'd30279;
     parameter b6_100_1k =  16'd14116;
//     parameter yiwei_1_100_1k =  16'd6;
//     parameter yiwei_2_100_1k =  16'd5; 
/*          1k-3k        */   

     parameter a1_1k_3k =  16'd1966 ;//X
     parameter a2_1k_3k =  16'd0;
     parameter a3_1k_3k =  -16'd1966;     
     parameter a4_1k_3k =  16'd1966;
     parameter a5_1k_3k =  16'd0;
     parameter a6_1k_3k =  -16'd1966; 
     parameter b1_1k_3k =  16'd16;   //Y
     parameter b2_1k_3k =  -16'd30704;
     parameter b3_1k_3k =  16'd14659;
     parameter b4_1k_3k =  16'd16;
     parameter b5_1k_3k =  -16'd27287;
     parameter b6_1k_3k =  16'd12647;
//     parameter yiwei_1_1k_3k =  16'd6;
//     parameter yiwei_2_1k_3k =  16'd5; 

/*          3k-5k        */   
     parameter a1_3k_5k =  16'd1966 ;//X
     parameter a2_3k_5k =  16'd0;
     parameter a3_3k_5k =  -16'd1966;     
     parameter a4_3k_5k =  16'd1966;
     parameter a5_3k_5k =  16'd0;
     parameter a6_3k_5k =  -16'd1966; 
     parameter b1_3k_5k =  16'd16;   //Y
     parameter b2_3k_5k =  -16'd24232;
     parameter b3_3k_5k =  16'd13199;
     parameter b4_3k_5k =  16'd16;
     parameter b5_3k_5k =  -16'd27761;
     parameter b6_3k_5k =  16'd14044;
//     parameter yiwei_1_3k_5k =  16'd6;
//     parameter yiwei_2_3k_5k =  16'd5; 
//     

/*          5k-8k        */   
     parameter a1_5k_8k =  16'd3056 ;//X
     parameter a2_5k_8k =  16'd0;
     parameter a3_5k_8k =  -16'd3056;     
     parameter a4_5k_8k =  16'd3056;
     parameter a5_5k_8k =  16'd0;
     parameter a6_5k_8k =  -16'd3056; 
     parameter b1_5k_8k =  16'd16;   //Y
     parameter b2_5k_8k =  -16'd20931;
     parameter b3_5k_8k =  16'd12567;
     parameter b4_5k_8k =  16'd16;
     parameter b5_5k_8k =  -16'd13402;
     parameter b6_5k_8k =  16'd11679;
//     parameter yiwei_1_5k_8k =  16'd6;
//     parameter yiwei_2_5k_8k =  16'd5; 

/*          10k-20k        */   
//     parameter a1_10k_20k =  16'd8215 ;//X
//     parameter a2_10k_20k =  16'd0;
//     parameter a3_10k_20k =  -16'd8215;     
//     parameter a4_10k_20k =  16'd8215;
//     parameter a5_10k_20k =  16'd0;
//     parameter a6_10k_20k =  -16'd8215; 
//     parameter b1_10k_20k =  16'd16;   //Y
//     parameter b2_10k_20k =  16'd26187;
//     parameter b3_10k_20k =  16'd11223;
//     parameter b4_10k_20k =  16'd16;
//     parameter b5_10k_20k =  -16'd967;
//     parameter b6_10k_20k =  16'd4229;
//     parameter yiwei_1_10k_20k =  16'd6;
//     parameter yiwei_2_10k_20k =  16'd5; 

/*          8k-16k        */   
//     parameter a1_10k_20k =  16'd2895 ;//X
//     parameter a2_10k_20k =  16'd0;
//     parameter a3_10k_20k =  -16'd2895;     
//     parameter a4_10k_20k =  16'd2895;
//     parameter a5_10k_20k =  16'd0;
//     parameter a6_10k_20k =  -16'd2895; 
//     parameter b1_10k_20k =  16'd16;   //Y
//     parameter b2_10k_20k =  -16'd28549;
//     parameter b3_10k_20k =  16'd13499;
//     parameter b4_10k_20k =  16'd16;
//     parameter b5_10k_20k =  -16'd22779;
//     parameter b6_10k_20k =  16'd411266;
//     parameter yiwei_1_10k_20k =  16'd6;
//     parameter yiwei_2_10k_20k =  16'd5; 

/*          6k-15k        */   
     parameter a1_6k_15k =  16'd2238 ;//X
     parameter a2_6k_15k =  16'd0;
     parameter a3_6k_15k =  -16'd2238;     
     parameter a4_6k_15k =  16'd2238;
     parameter a5_6k_15k =  16'd0;
     parameter a6_6k_15k =  -16'd2238; 
     parameter b1_6k_15k =  16'd16;   //Y
     parameter b2_6k_15k =  -16'd29802;
     parameter b3_6k_15k =  16'd14189;
     parameter b4_6k_15k =  16'd16;
     parameter b5_6k_15k =  -16'd25864;
     parameter b6_6k_15k =  16'd412350;


   mix_filter_32bits   
#(
     .a1(a1_100_1k), 
     .a2(a2_100_1k),
     .a3(a3_100_1k),
     .a4(a4_100_1k),
     .a5(a5_100_1k),
     .a6(a6_100_1k),  
     .b1(b1_100_1k), 
     .b2(b2_100_1k),
     .b3(b3_100_1k),
     .b4(b4_100_1k),
     .b5(b5_100_1k),
     .b6(b6_100_1k)
    )filter_100_1k( 
        .clk(clk),
        .reset_n(reset),
        .valid_in(clk_enable),
        .audio_in(filter_in),
        .audio_out(filter_out[0]),
        .valid_out(),
     .yiwei_1(filter_gain_100_1k_1),
     .yiwei_2(filter_gain_100_1k_2));




 mix_filter_32bits   
#(
     .a1(a1_1k_3k), 
     .a2(a2_1k_3k),
     .a3(a3_1k_3k),
     .a4(a4_1k_3k),
     .a5(a5_1k_3k),
     .a6(a6_1k_3k),  
     .b1(b1_1k_3k), 
     .b2(b2_1k_3k),
     .b3(b3_1k_3k),
     .b4(b4_1k_3k),
     .b5(b5_1k_3k),
     .b6(b6_1k_3k)
    )filter_1k_3k( 
        .clk(clk),
        .reset_n(reset),
        .valid_in(clk_enable),
        .audio_in(filter_in),
        .audio_out(filter_out[1]),
        .valid_out(),
      .yiwei_1(filter_gain_1k_3k_1),
     .yiwei_2(filter_gain_1k_3k_2));



  mix_filter_32bits   
#(
     .a1(a1_3k_5k), 
     .a2(a2_3k_5k),
     .a3(a3_3k_5k),
     .a4(a4_3k_5k),
     .a5(a5_3k_5k),
     .a6(a6_3k_5k),  
     .b1(b1_3k_5k), 
     .b2(b2_3k_5k),
     .b3(b3_3k_5k),
     .b4(b4_3k_5k),
     .b5(b5_3k_5k),
     .b6(b6_3k_5k)
    )filter_3k_5k( 
        .clk(clk),
        .reset_n(reset),
        .valid_in(clk_enable),
        .audio_in(filter_in),
        .audio_out(filter_out[2]),
        .valid_out(),
     .yiwei_1(filter_gain_3k_5k_1),
     .yiwei_2(filter_gain_3k_5k_2));



  mix_filter_32bits   
#(
     .a1(a1_5k_8k), 
     .a2(a2_5k_8k),
     .a3(a3_5k_8k),
     .a4(a4_5k_8k),
     .a5(a5_5k_8k),
     .a6(a6_5k_8k),  
     .b1(b1_5k_8k), 
     .b2(b2_5k_8k),
     .b3(b3_5k_8k),
     .b4(b4_5k_8k),
     .b5(b5_5k_8k),
     .b6(b6_5k_8k)
    )filter_5k_8k( 
        .clk(clk),
        .reset_n(reset),
        .valid_in(clk_enable),
        .audio_in(filter_in),
        .audio_out(filter_out[3]),
        .valid_out(),
     .yiwei_1(filter_gain_5k_8k_2),
     .yiwei_2(filter_gain_5k_8k_2));
       


  mix_filter_32bits   
#(
     .a1(a1_6k_15k), 
     .a2(a2_6k_15k),
     .a3(a3_6k_15k),
     .a4(a4_6k_15k),
     .a5(a5_6k_15k),
     .a6(a6_6k_15k),  
     .b1(b1_6k_15k), 
     .b2(b2_6k_15k),
     .b3(b3_6k_15k),
     .b4(b4_6k_15k),
     .b5(b5_6k_15k),
     .b6(b6_6k_15k)
    )filter_6k_15k( 
        .clk(clk),
        .reset_n(reset),
        .valid_in(clk_enable),
        .audio_in(filter_in),
        .audio_out(filter_out[4]),
        .valid_out(),
     .yiwei_1(filter_gain_6k_15k_1),
     .yiwei_2(filter_gain_6k_15k_2));      




   always @( posedge clk or negedge reset)
    
      if (!reset) filter_out_all <= 0;
      else begin
      filter_out_all <=  filter_out_a  + filter_out[0] + filter_out[1] + filter_out[2] + filter_out[3] + filter_out[4]   ;
     

        end
       

endmodule
