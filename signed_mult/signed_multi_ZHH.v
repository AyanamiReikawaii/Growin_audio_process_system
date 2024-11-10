module multiplier (
    input wire clk,
    input wire rst,
    input wire [15:0] X,
    input wire [15:0] Y,
    output  reg [31:0] product
);

    reg [31:0] P;
    reg [15:0] Q;
    reg [5:0] count;
    wire [15:0] X_abs;
    wire [15:0] Y_abs;
    reg [15:0] X_reg;
    reg [15:0] Y_reg;

    assign X_abs = (X[15]==1) ? ~X + 1 : X ;            //!求绝对值
    assign Y_abs = (Y[15]==1) ? ~Y + 1 : Y ;            
    

    always @(posedge clk or negedge rst)                //!计数器
    begin
        if (!rst)
            count <= 6'd0;
        else if (count == 6'd33)
            count <= 6'd0;
        else
            count <= count + 6'd1;
    end

    always @(posedge clk or negedge rst)
    begin

        if (!rst) begin
            P <= 16'd0;
            Q <= 16'd0;
        end
        else if (count == 6'd0) begin                    //!count 为0则置初始值
            P <= 16'd0; 
            Q <= Y_abs;                                //TODO: P15.....P0 Q15....
            X_reg<=X;
            Y_reg<=Y;
        end

        else if(count[0]==6'd1 && count[0]!=6'd33)begin     //!count 为1、3、5、7......31 则加法运算（共16次）
            
            if(Q[0]==1)begin
                P<=P+X_abs;
                Q<=Q;
            end
            else begin
                P<=P;
                Q<=Q;
            end

        end

        else if(count[0]==6'd0 && count!=6'd0)begin     //!count 为2、4、6、8......32 则右移（共16次）

            {P,Q}<={P,Q}>>1;

        end



    end


always @(posedge clk or negedge rst)                //!计数器
    begin

        if (!rst) begin
            product<=32'd0;
        end
        else if(count==6'd33&&X==X_reg&&Y==Y_reg)begin

            if(X[15] ^ Y[15]==1'b0)                                            //!count 为33 则输出结果
                product <= {P[15:0],Q[15:0]};
            else
                product <=  ~ { P[15:0], Q[15:0] } + 1;                //!输出补码

        end
   
    end

endmodule

 