module freq_div40k#(
    parameter CNT_MAX = 11'd2000
)
(
    clk,
    rst_n,
    freq_40k
);
    
    input clk;
    input rst_n;
    output reg freq_40k;
    
    reg [10:0]cnt;
    
    always@(posedge clk or negedge rst_n)
    if(!rst_n)begin 
        cnt <= 'b0;
        freq_40k <= 'b0;
    end
    else if(cnt >= CNT_MAX - 1'b1)begin
        cnt <= 'b0;
        freq_40k <= ~freq_40k;
    end
    else
        cnt <= cnt + 1'b1;
    
endmodule
