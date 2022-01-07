module rfile(R1,R2,W,WD,Wctl,RD1,RD2,clock);
   input [4:0] R1,R2,W;   // Select what to read/write
   input [63:0] WD;
   input 	Wctl, clock;
   output [63:0] RD1,RD2;
   reg [63:0] 	 RF[31:0];
   assign RD1 = RF[R1];
   assign RD2 = RF[R2];
   always @(posedge clock)
     if (Wctl) RF[W] <= WD;
endmodule

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

module mult4_stg(mr,a,b,start,clk, rst);
   parameter WIDTH = 4;
   input [WIDTH-1:0]        a, b;       //input a b are 4 bits
   output reg [2*WIDTH-1:0] mr;         //output is 8 bits
   input 		            start, clk, rst;
   wire [2*WIDTH-1:0] 	    m;

   mult4 mult(m, a, b);
   always @(negedge rst) begin
      mr = {(2*WIDTH){1'b0}};
   end
   always @(posedge clk) begin
      if (start) mr = m;
   end 
endmodule 

//mult8_stg instantiates 4 mult4_stg modules
module mult8_stg (mr,a,b,start,clk, rst);//(m,a,b); //
   parameter WIDTH = 8; 
   input [WIDTH-1:0]            a, b;       //inputs a b are 8 bits 
   output reg [2*WIDTH-1:0]     mr;          //output is 16 bits (8 x 8)
   wire [WIDTH-1:0] 	        a1b1, a1b0, a0b1, a0b0;
   wire [WIDTH:0] 	            a1b0pa0b1;
   wire 		                nowhere;
   wire [2*WIDTH-1:0]           m;
   input                        clk, rst, start;
   
   mult4_stg m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2], start, clk, rst);        //(mr,a,b,start,clk, rst); mr is 8 bits, a,b are 4 bits
   mult4_stg m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0], start, clk, rst);
   mult4_stg m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2], start, clk, rst);
   mult4_stg m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0], start, clk, rst);

   yAdder #(WIDTH) a0(a1b0pa0b1[WIDTH-1:0], a1b0pa0b1[WIDTH], a1b0, a0b1, 1'b0);
   yAdder #(2*WIDTH) a1(m, nowhere,  {a1b1,a0b0},  {{(WIDTH/2-1){1'b0}},a1b0pa0b1,{(WIDTH/2){1'b0}}}, 1'b0);

   always @(negedge rst) begin
      mr = {(2*WIDTH){1'b0}};
   end
   always @(posedge clk) begin
      if(start) mr=m;
   end
endmodule

module mult_width(mr,a,b,start,clk, rst);
   parameter WIDTH = 16;
    input [WIDTH-1:0]       a, b;
    input                   start, clk, rst;
    output reg [2*WIDTH-1:0] mr;
    wire [WIDTH-1:0] 	     a1b1, a1b0, a0b1, a0b0;
    wire [WIDTH:0] 	         a1b0pa0b1;
    wire [2*WIDTH-1:0]       m;

    generate            //used for loops and conditions
    if(WIDTH==8)begin  //insantiate 4 mult4_stg modules
        mult4_stg m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2], start, clk, rst);        //(mr,a,b,start,clk, rst); mr is 8 bits, a,b are 4 bits
        mult4_stg m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0], start, clk, rst);
        mult4_stg m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2], start, clk, rst);
        mult4_stg m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0], start, clk, rst);
    end
    else begin    //insantiate 4 mult_width modules with half the WIDTH as parameter (plus two adder modules)
        mult_width #(WIDTH/2) m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2], start, clk, rst);        //(mr,a,b,start,clk, rst); mr is 8 bits, a,b are 4 bits
        mult_width #(WIDTH/2) m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0], start, clk, rst);
        mult_width #(WIDTH/2) m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2], start, clk, rst);
        mult_width #(WIDTH/2) m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0], start, clk, rst);
    end
    endgenerate
    yAdder #(WIDTH) a0(a1b0pa0b1[WIDTH-1:0], a1b0pa0b1[WIDTH], a1b0, a0b1, 1'b0);
    yAdder #(2*WIDTH) a1(m, nowhere,  {a1b1,a0b0},  {{(WIDTH/2-1){1'b0}},a1b0pa0b1,{(WIDTH/2){1'b0}}}, 1'b0);

    always @(negedge rst) begin
      mr = {(2*WIDTH){1'b0}};
   end
   always @(posedge clk) begin
      if(start) mr=m;
   end
endmodule // mult4_stg

module mult_pipe(mr,a,b,start,Rdin,Rdout,clk, rst);
   parameter WIDTH = 16;
   localparam levels = $clog2(WIDTH)-1;

   output reg [2*WIDTH-1:0] mr;
   input [WIDTH-1:0]        a, b;
   input                    start, rst, clk;
   input [4:0]              Rdin;       //Similar to WB. The destination register for product of a and b.
   output [4:0]             Rdout;      //The destination register for mr
   wire [2*WIDTH-1:0]       m;
   reg  [4:0]               RD1[levels-1:0];

    generate
        genvar i;
        for(i=0; i<levels-1; i=i+1)begin
            mult_width #(WIDTH) mult(m,a,b,start, clk, rst);
            always @(posedge clk)begin
                RD1[i+1]<=RD1[i];
            end
        end
        assign Rdout=RD1[levels-1];    //rightmost register
    endgenerate

   always @(negedge rst) begin
      mr = {(2*WIDTH){1'b0}};
   end
   always @(posedge clk) begin
      if(start) mr<=m;
      RD1[0]<=Rdin;
   end
endmodule // mult_pipe


module LabM;
   parameter WIDTH = 32;
   reg [WIDTH-1:0]      a, b;
   wire [2*WIDTH-1:0]   m;
   integer 	            i,j;
   reg [2*WIDTH-1:0]    expm;
   reg 		            clk, rst, start;
   reg [4:0] 	        Rdin;
   wire [4:0] 	        Rdout;

  //  mult_width #(WIDTH) mult(m,a,b,start, clk, rst);
    //mult8_stg #(WIDTH) mult8(m,a,b,start, clk, rst);
   mult_pipe #(WIDTH) testm(m, a, b, start, Rdin, Rdout, clk, rst);
   initial begin
      clk   = 1'b0;
      rst   = 1'b0; #1 rst   = 1'b1; #1 rst   = 1'b0; 
      start = 1'b0;
      #1 rst = 1'b1; #1;
      for (i=0; i<40; i=i+1) begin
	 a = $random;
	 b = $random;
	 Rdin = i;
	 expm = a*b;
	 start = 1'b1;
	 #1 clk = 1'b1;
	 #1 clk = 1'b0;
     //$display($time, ", a: %d, b: %d, m: %d, expm: %d", a, b, m,  expm);
	 $display($time, ", a: %d, b: %d, m: %d, Rdout: %d, expm: %d, Rdin: %d", a, b, m, Rdout, expm, Rdin);
      end
      $finish;
   end // initial begin
endmodule // LabM