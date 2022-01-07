//Lian Attily   |   Lab A1 thursday |   Lab M   | November 19th, 2020   |   A multi-bit multiplier

module yAdder1(z, cout, a, b, cin); 
   output z, cout; 
   input  a, b, cin; 
   xor left_xor(tmp, a, b); 
   xor right_xor(z, cin, tmp); 
   and left_and(outL, a, b); 
   and right_and(outR, tmp, cin); 
   or my_or(cout, outR, outL); 
endmodule // yAdder1

module yAdder(s, cout, a, b, cin);
   parameter SIZE = 2;
   output [SIZE-1:0] s; 
   output 	     cout; 
   input [SIZE-1:0]  a, b; 
   input 	     cin; 
   wire [SIZE-1:0]   in, out; 
   yAdder1 mine[SIZE-1:0](s, out, a, b, in); 
   assign {cout,in} = {out,cin};
endmodule // yAdder

module mult2(m, a, b);
    output [3:0] m;
    input [1:0] a,b;

    assign m[0] = a[0] & b[0];
    assign m[1] = (a[1] & ~b[1] & b[0]) | (a[1] & ~a[0] & b[0]) | (~a[1] & a[0] & b[1]) | (a[0] & b[1] & ~b[0]);   //a1b1`b0 + a1a0`b0 + a1`a0b1 + a0b1b0'
    assign m[2] = (a[1] & ~a[0] & b[1]) | (a[1] & b[1] & ~b[0]);  //a1a0`b1 + a1b1b0`
    assign m[3] = a[1] & a[0] & b[1] & b[0];

endmodule

module mult4(m, a, b);
    parameter WIDTH=4;  
    output [2*WIDTH-1:0] m; //8 bits
    input [WIDTH-1:0] a,b;  //4 bits

    wire [WIDTH-1:0] a1b1, a0b0, a1b0, a0b1;    //4 bits
    wire [1:0] a1, b1, a0, b0;  //2 bits

    assign a1=a[WIDTH-1:WIDTH/2];
    assign a0=a[WIDTH/2-1:0];
    assign b1=b[WIDTH-1:WIDTH/2];
    assign b0=b[WIDTH/2-1:0];

    mult2 A1B1(a1b1, a1, b1);
    mult2 A0B0(a0b0, a0, b0);
    mult2 A1B0(a1b0, a1, b0);
    mult2 A0B1(a0b1, a0, b1);

    wire [WIDTH:0] adder1;        //5 bits
    
    yAdder #(WIDTH) first(adder1[WIDTH-1:0], adder1[WIDTH], a1b0, a0b1,1'b0);    //output is 4 bits + cout is one bit 
    yAdder #(2*WIDTH) second(m, nowhere, {a1b1, a0b0}, {{(WIDTH/2-1){1'b0}},adder1,{(WIDTH/2){1'b0}}}, 1'b0);

endmodule
    
module mult_stg(mr, a, b, start, clk, rst);
    parameter WIDTH=4;
    input start, clk, rst;
    input [WIDTH-1:0] a, b;
    output reg [2*WIDTH-1:0] mr;
    wire [2*WIDTH-1:0] m;
    
    mult4 mult(m, a, b);            //insantiation

    always @(negedge rst)begin
      mr<={(2*WIDTH){1'b0}};      //OR use assign instead of non-blocking assignment??
    end 

    always @(posedge clk) begin
      if(start) mr<=m;
    end
endmodule

module testbench;
    parameter WIDTH=4;
    reg [2*WIDTH-1:0] expect;
    reg [WIDTH-1:0] a, b;
    wire [2*WIDTH-1:0] mr;
    reg start, clk, rst;
    integer i, j;

    mult_stg mystg(mr, a, b, start, clk, rst);

    initial 
    begin
    clk   = 1'b0;
    rst   = 1'b0; #1 rst   = 1'b1; #1 rst   = 1'b0; 
    start = 1'b0;
    #1 rst = 1'b1; #1;
    for (i=0; i<10; i=i+1) 
    begin
        a = $random;
        b = $random;
        expect = a*b;
        start = 1'b1;
        #1 clk = 1'b1;
       // #1 if(expect!=mr)
        #1$display($time, ", a: %d, b: %d, m: %d, expm: %d", a, b, mr, expect);      //display only if fail
        #1 clk = 1'b0;
        #1 if(expect===mr) $display($time, ", a: %d, b: %d, m: %d, expm: %d", a, b, mr, expect);     //display only if fail
    end
    $finish;
    end //end for initial begin
endmodule