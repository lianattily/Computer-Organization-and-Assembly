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
   output        cout; 
   input [SIZE-1:0]  a, b; 
   input         cin; 
   wire [SIZE-1:0]       in, out; 
   yAdder1 mine[SIZE-1:0](s, out, a, b, in); 
   assign {cout,in} = {out,cin};
endmodule // yAdder

module mult2(m,a,b);
   input [1:0] a, b;
   output [3:0] m;

   assign m[3] = a[1]&a[0]&b[1]&b[0];
   assign m[2] = a[1]&~a[0]&b[1] | a[1]&b[1]&~b[0];
   assign m[1] = a[1]&b[0]&(~b[1]|~a[0]) | a[0]&b[1]&(~a[1]|~b[0]);
   assign m[0] = a[0]&b[0];
endmodule // mult2

module mult4(m,a,b);
   parameter WIDTH = 4;
   input [WIDTH-1:0]        a, b;
   output [2*WIDTH-1:0]     m;
   wire [WIDTH-1:0] 	    a1b1, a1b0, a0b1, a0b0;
   wire [WIDTH:0] 	    a1b0pa0b1;
   wire 		    nowhere;
   
   mult2 m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2]);
   mult2 m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0]);
   mult2 m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2]);
   mult2 m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0]);

   yAdder #(WIDTH) a0(a1b0pa0b1[WIDTH-1:0],a1b0pa0b1[WIDTH],a1b0,a0b1,1'b0);
   yAdder #(2*WIDTH) a1(m, nowhere,
			  {a1b1,a0b0},
			  {{(WIDTH/2-1){1'b0}},a1b0pa0b1,{(WIDTH/2){1'b0}}},1'b0);
endmodule // mult4

module mult4_stg(mr,a,b,start,clk, rst);
   parameter WIDTH = 4;
   input [WIDTH-1:0]        a, b;
   output reg [2*WIDTH-1:0] mr;
   input 		    start, clk, rst;
   wire [2*WIDTH-1:0] 	    m;

   mult4 mult(m, a, b);
   always @(negedge rst) begin
      mr = {(2*WIDTH){1'b0}};
   end
   always @(posedge clk) begin
      if (start) mr = m;
   end // always @ (posedge clk)
endmodule // mult4_stg

module mult8_stg(mr,a,b,start,clk, rst);
   parameter WIDTH = 8;

endmodule // mult4_stg

/* -----\/----- EXCLUDED -----\/-----

module mult_width(mr,a,b,start,clk, rst);
   parameter WIDTH = 16;

endmodule // mult4_stg

module mult_pipe(mr,a,b,start,Rdin,Rdout,clk, rst);
   parameter WIDTH = 16;

endmodule // mult_pipe
 -----/\----- EXCLUDED -----/\----- */

   
module LabM;
   parameter WIDTH = 32;
   
/* -----\/----- EXCLUDED -----\/-----
   reg [WIDTH-1:0]    a, b;
   wire [2*WIDTH-1:0] m;
   integer 	      i,j;
   reg [2*WIDTH-1:0]  expm;
   reg 		      clk, rst, start;
   reg [4:0] 	      Rdin;
   wire [4:0] 	      Rdout;

   mult_pipe #(WIDTH) testm(m, a, b, start, Rdin, Rdout, clk, rst);
   initial begin
      clk   = 1'b0;
      rst   = 1'b0; #1 rst   = 1'b1; #1 rst   = 1'b0; 
      start = 1'b0;
      #1 rst = 1'b1; #1;
      for (i=0; i<40; i++) begin
	 a = $random;
	 b = $random;
	 Rdin = i;
	 expm = a*b;
	 start = 1'b1;
	 #1 clk = 1'b1;
	 #1 clk = 1'b0;
	 $display($time, ", a: %d, b: %d, m: %d, Rdout: %d, expm: %d, Rdin: %d", a, b, m, Rdout, expm, Rdin);
      end
      $finish;
   end // initial begin
 -----/\----- EXCLUDED -----/\----- */
endmodule // LabM
/* -----\/----- EXCLUDED -----\/-----
   mult4_stg testm(m, a, b, start, clk, rst);

   initial begin
      clk   = 1'b0;
      rst   = 1'b0; #1 rst   = 1'b1; #1 rst   = 1'b0; 
      start = 1'b0;
      #1 rst = 1'b1; #1;
      for (i=0; i<10; i++) begin
	 a = $random;
	 b = $random;
	 expm = a*b;
	 start = 1'b1;
	 #1 clk = 1'b1;
	 #1 $display($time, ", a: %d, b: %d, m: %d, expm: %d", a, b, m, expm);
	 #1 clk = 1'b0;
	 #1 $display($time, ", a: %d, b: %d, m: %d, expm: %d", a, b, m, expm);
      end
      $finish;
   end // initial begin
 -----/\----- EXCLUDED -----/\----- */

/* -----\/----- EXCLUDED -----\/-----

   initial begin
      for (i=0; i<2**WIDTH; i++)
	for (j=0; j<2**WIDTH; j++) begin
	   a = i;
	   b = j;
	   expm = i*j;
	   #1 if (expm == m)
	     $display("PASS: a: %d, b: %d, m: %d, expm: %d", a, b, m, expm);
	   else
	     $display("FAIL: a: %4b, b: %4b, m: %8b, expm: %8b", a, b, m, expm);
	end
      $finish;
   end // initial begin	   
 -----/\----- EXCLUDED -----/\----- */

/* -----\/----- EXCLUDED -----\/-----
   mult2 testm(m, a, b);

   initial begin
      for (i=0; i<4; i++)
	for (j=0; j<4; j++) begin
	   a = i;
	   b = j;
	   expm = i*j;
	   #1 if (expm == m)
	     $display("PASS: a: %2b, b: %2b, m: %4b, expm: %4b", a, b, m, expm);
	   else
	     $display("FAIL: a: %2b, b: %2b, m: %4b, expm: %4b", a, b, m, expm);
	end
      $finish;
   end // initial begin	     
 -----/\----- EXCLUDED -----/\----- */
	  