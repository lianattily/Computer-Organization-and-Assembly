//Lian Attily | Section A | Lab M | Nov. 19, 2020 | Simulate a 4-bit multiplier

module mult2(m, a, b);
    output [3:0] m;         //product of a * b
    input [1:0] a, b;       //a= first factor of product   //b=second factor of product

    assign m[0] = a[0] & b[0];
    assign m[1] = (a[1] & ~b[1] & b[0]) | (a[1] & a[0] & ~b[0]) | (~a[1] & a[0] & b[1]) | (a[0] & b[1] & ~b[0]);   //a1b1`b0 + a1a0`b0 + a1`a0b1 + a0b1b0'
    assign m[2] = (a[1] & ~a[0] & b[1]) | (a[1] & ~b[1] & b[0]);  //a1a0`b1 + a1b1b0`
    assign m[3] = a[1] & a[0] & b[1] & b[0];
endmodule

module mult4(m, a, b);
    parameter WIDTH=8;
    output [WIDTH-1:0] m;
    input [WIDTH/2:0] a,b;

    mult2 upper(m[3:0], a[1:0], b[1:0]);
    mult2 lower(m[7:4], a[3:2], b[3:2]);


endmodule

module mult_stg(mr, a, b, start, clk, rst);
    output mr;
    input a,b;
    input start, clk, rst;

    always @(posedge rst)
        mr<=1'b0;

    always @(posedge clk) begin
        if(start) mult4(mr, a, b);
    end
endmodule

module testbench;
    parameter WIDTH=4;
    wire mr;
    reg a, b;
    reg start, clk, rst;
    reg i, j;
    
    mult_stg mine(mr, a, b, start, clk, rst);

    initial
    begin
        clk=0; rst=0; start=1;
        for(i=0; i<2**WIDTH; i=i+1)begin
            for(j=0; j<2**WIDTH; j=j+1)begin
                a=i; b=j;

                #1;
                $display("a=%b  b=%b  clk=%b  mr=%b", a, b, clk, mr);
            end
        end
            
    end
    always
    begin
            #1 clk = ~clk;
            #1 rst = ~rst;
    end
endmodule