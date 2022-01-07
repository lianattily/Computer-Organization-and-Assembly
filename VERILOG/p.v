//Lian Attily  |  Labtest2 | December 4th, 2020    |  Section A
//Q2: stage1: pipelines addition   stage2: decodes, executes, and writes back (ADD/ADDI/MULT)  stage3: fetches instruction from memory to be decoded/executed/WB

module rfile(R1,R2,W,WD,Wctl,RD1,RD2,clock,rst);
   parameter WIDTH = 16;
   input [4:0]            R1,R2,W;   // Select what to read/write
   input [WIDTH-1:0] 	  WD;
   input 	          Wctl, clock, rst;
   output [WIDTH-1:0] 	  RD1,RD2;
   reg signed [WIDTH-1:0] RF[31:0];
   genvar 		  i;
   
   assign RD1 = RF[R1];
   assign RD2 = RF[R2];
   generate
      for (i=0; i<32; i=i+1)begin:blk
	always @(negedge rst) begin
	   RF[i] <= {WIDTH{1'b0}};
	end
      end
   endgenerate
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

module yMux1(z, a, b, c); 
   output z; 
   input  a, b, c; 
   wire   notC, upper, lower; 
   not my_not(notC, c); 
   and upperAnd(upper, a, notC); 
   and lowerAnd(lower, c, b); 
   or my_or(z, upper, lower); 
endmodule // yMux1

module yMux(z, a, b, c); 
   parameter SIZE = 7; 
   output [SIZE-1:0] z; 
   input [SIZE-1:0]  a, b; 
   input             c; 
   yMux1 mine[SIZE-1:0](z, a, b, c); 
endmodule // yMux

module yMux4to1(z, a0,a1,a2,a3, c); 
   parameter SIZE = 2; 
   output [SIZE-1:0] z; 
   input [SIZE-1:0]  a0, a1, a2, a3; 
   input [1:0]       c; 
   wire [SIZE-1:0]   zLo, zHi; 
   yMux #(SIZE) lo(zLo, a0, a1, c[0]); 
   yMux #(SIZE) hi(zHi, a2, a3, c[0]); 
   yMux #(SIZE) final(z, zLo, zHi, c[1]); 
endmodule // yMux4to1

module yMux8to1(z, a0,a1,a2,a3, a4, a5, a6, a7, c); 
   parameter SIZE = 2; 
   output [SIZE-1:0] z; 
   input [SIZE-1:0]  a0, a1, a2, a3, a4, a5, a6, a7; 
   input [2:0]       c; 
   wire [SIZE-1:0]   zLo, zHi; 
   yMux4to1 #(SIZE) lo(zLo, a0, a1, a2, a3, c[1:0]); 
   yMux4to1 #(SIZE) hi(zHi, a4, a5, a6, a7, c[1:0]); 
   yMux #(SIZE) final(z, zLo, zHi, c[2]); 
endmodule // yMux4to1

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

module mult_width(mr,a,b,start,clk, rst);
   parameter WIDTH = 16;
   input [WIDTH-1:0]        a, b;
   output reg [2*WIDTH-1:0] mr;
   input 		    start, clk, rst;
   wire [2*WIDTH-1:0] 	    m;
   wire [WIDTH-1:0] 	    a1b1, a1b0, a0b1, a0b0;
   wire [WIDTH:0] 	    a1b0pa0b1;
   wire 		    nowhere;

   generate
      if (WIDTH==8) begin
	 mult4_stg m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2],start,clk, rst);
	 mult4_stg m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0],start,clk, rst);
	 mult4_stg m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2],start,clk, rst);
	 mult4_stg m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0],start,clk, rst);
      end
      else begin
	 mult_width #(WIDTH/2) m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2],start,clk, rst);
	 mult_width #(WIDTH/2) m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0],start,clk, rst);
	 mult_width #(WIDTH/2) m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2],start,clk, rst);
	 mult_width #(WIDTH/2) m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0],start,clk, rst);
      end // else: !if(WIDTH==8)
      
      yAdder #(WIDTH) a0(a1b0pa0b1[WIDTH-1:0],a1b0pa0b1[WIDTH],a1b0,a0b1,1'b0);
      yAdder #(2*WIDTH) a1(m, nowhere,
			   {a1b1,a0b0},
			   {{(WIDTH/2-1){1'b0}},a1b0pa0b1,{(WIDTH/2){1'b0}}},1'b0);
   endgenerate
   always @(negedge rst) begin
      mr = {(2*WIDTH){1'b0}};
   end
   always @(posedge clk) begin
      if (start) mr = m;
   end // always @ (posedge clk)
endmodule // mult4_stg

module mult_pipe(mr,a,b,start,Rdin,Rdout,clk, rst);
   parameter WIDTH = 16;
   localparam levels = $clog2(WIDTH)-1;
   
   input [WIDTH-1:0]       a, b;
   output [2*WIDTH-1:0]    mr;
   input [4:0] 		   Rdin;
   output [4:0] 	   Rdout;
   input 		   start, clk, rst;
   reg [4:0] 		   Rd_pipe[levels-1:0];
   genvar 		   i;

   mult_width #(WIDTH) mw(mr,a,b,start,clk, rst);
   generate
      for (i=0; i<levels; i = i+1)
	always @(negedge rst)
	  Rd_pipe[i] = {5{1'b0}};
      for (i=0; i<levels-1; i = i+1)
	always @(posedge clk) 
	  if (start) Rd_pipe[i+1] <= Rd_pipe[i];
   endgenerate
   always @(posedge clk) 
     if (start) Rd_pipe[0] <= Rdin;
   assign Rdout = Rd_pipe[levels-1];

endmodule // mult_pipe


module add_pipe(mr,a,b,start,Rdin,Rdout,clk, rst);    //pipelines addition similar to mult_pipe (except, addition is done in one cycle)
   parameter WIDTH = 16;
   localparam levels = $clog2(WIDTH)-1;
   
   input [WIDTH-1:0]       a, b;
   output [WIDTH-1:0]      mr;
   input [4:0] 		      Rdin;
   output [4:0] 	         Rdout;
   input 		            start, clk, rst;
   wire                    cout;
   reg [4:0] 		         Rd_pipe[levels-1:0];
   reg [WIDTH-1:0]         regs[levels-1:0];
   wire [WIDTH-1:0]        temp;
   genvar 		            i;

   yAdder #(WIDTH) yadd(temp, cout, a,b,1'b0);
   generate
      for (i=0; i<levels; i = i+1)
         always @(negedge rst)begin
             Rd_pipe[i] = {5{1'b0}};     //reset pipe add registers
             regs[i]={5{1'b0}};
         end
      for (i=0; i<levels-1; i = i+1)
         always @(posedge clk) 
            if (start)begin 
               Rd_pipe[i+1] <= Rd_pipe[i];
               regs[i+1]<=regs[i];     //moving results of addition along the way
            end
   endgenerate

   always @(posedge clk) 
     if (start) begin 
        Rd_pipe[0] <= Rdin;
        regs[0] <= temp;
     end
     assign Rdout = Rd_pipe[levels-1];
     assign mr = regs[levels-1];

endmodule // add_pipe


module idexwb_pipe(res, Rdout, opcode, Rs1, Rs2, Rd, imm, start, clk, rst);      //decode - execute - write back instructions (mul, add, addi, nop)
   parameter WIDTH = 32;
   output [WIDTH-1:0]   res;
   output [4:0]         Rdout;
   input                start, clk, rst;
   input [2:0]          opcode;
   input  signed [11:0] imm;
   input [4:0] 		   Rs1, Rs2, Rd;     

   wire                 Wctl;
   wire  [WIDTH-1:0]    RD1, RD2;
   wire  [4:0]          RinA, RinM,pickRM, pickRA,outM, outA;
   wire [WIDTH-1:0]     RD22, addres, pickRES;
   wire [2*WIDTH-1:0]   multres;
        

   //immS= imm sign extend with MSB
   wire [WIDTH-1:0] immS, pick;     
   assign immS = {{(WIDTH-12){imm[11]}},imm};

   //pick between RD2 and IMM (ADD vs ADDI)
   yMux #(WIDTH) pickrd(pick,  RD2, immS, (opcode[0]&opcode[1]));
   assign RD22=pick;
   //pick Rin for mult and add accordingly
   yMux #(5) pickM(pickRM, 5'b00000, Rd,  (opcode[1]&~opcode[0]));     
   assign RinM=pickRM;
   yMux #(5) pickA(pickRA, 5'b00000,Rd, ((opcode[0]&~opcode[1])|(opcode[0]&opcode[1]))); 
   assign RinA=pickRA;

   add_pipe #(WIDTH) madd(addres, RD1, RD22, start, RinA, outA, clk, rst);     
   mult_pipe #(WIDTH) mmult(multres, RD1, RD2, start, RinM, outM, clk, rst);  

   
   assign Rdout= (outA==5'b0000)? outM: outA;   //pick Rdout (whichever is non zero)
   assign res= (outA==5'b0000)? multres: addres; //pick res (whichever is nonzero)

   wire  outxor, Axor, Mxor;
   assign Axor=(outA[0]|outA[1]|outA[2]|outA[3]|outA[4]);
   assign Mxor=(outM[0]|outM[1]|outM[2]|outM[3]|outM[4]);
   assign outxor=Axor^Mxor;

   yMux1  wctrl(Wctl, 1'b0, 1'b1, outxor);      //Wctl=1 when only ONE of the Rdouts is non-zero

   rfile #(WIDTH) regs(Rs1, Rs2, Rdout, res, Wctl, RD1, RD2, clk, rst);

endmodule // idexwb_pipe

module predecode(opcode, Rs1, Rs2, Rd, imm, ins);
   parameter WIDTH = 16;
   output [2:0]         opcode;
   output [4:0] 	Rs1, Rs2, Rd;
   output [11:0] 	imm;
   input [31:0] 	ins;

   assign opcode = ins[2:0];
   assign Rs1    = ins[7:3];
   assign Rd     = ins[12:8];
   assign Rs2    = ins[17:13];
   assign imm    = ins[24:13];
endmodule // predecode

module if_pipe(ins, start, clk, rst);        //fetches instructions from compmem.dat
   parameter WIDTH=32;
   output reg [WIDTH-1:0] ins;
   input              start, clk, rst;
   reg [31:0] 	       imem[63:0];     
   reg [WIDTH-1:0]     PC;
   wire [WIDTH-1:0] PCp1;
   
   yAdder #(WIDTH) pcplus1(PCp1, cout, PC, 1, 1'b0); 

   always @(negedge rst)begin 
               ins<=0;
               $readmemb("compmem.dat", imem, 6'd0, 6'd22);
               PC<=0;
         end
   always @(posedge clk)begin
     if(start)begin
         ins<=imem[PC];
         PC<=PCp1;
      end
   end

endmodule // if_pipe

module Labtest;
   parameter WIDTH = 32;
   
   reg [WIDTH-1:0]    a, b, expa;
   wire [2*WIDTH-1:0] m;
   wire [WIDTH-1:0]   addout;
   integer 	      i,j;
   reg [2*WIDTH-1:0]  expm;
   reg 		      clk, rst, start;
   reg [4:0] 	      Rdin;
   wire [4:0] 	      Rdout;

   add_pipe #(WIDTH) testm(addout, a, b, start, Rdin, Rdout, clk, rst);
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
	 expa = (a+b) & {WIDTH{1'b1}};
	 start = 1'b1;
	 #1 clk = 1'b1;
	 #1 clk = 1'b0;
	 //$display($time, ", a: %d, b: %d, m: %d, Rdout: %d, expm: %d, Rdin: %d", a, b, m, Rdout, expm, Rdin);
	 $display($time, ", a: %d, b: %d, addout: %d, Rdout: %d, expa: %d, Rdin: %d", a, b, addout, Rdout, expa, Rdin);
      end
      $finish;
   end // initial begin
endmodule // LabM
