//Lian Attily   |   Labtest2    |   December 4th, 2020
//Q1: Increments value (a) by 1   

module cla_incr(S, g, p, a, cin);
   output S, p, g;
   input  a, cin;		// Using assign is perhaps the easiest here

   assign S = a^cin;
   assign g = 0;      //b is always 0 so its gonna b 0
   assign p = a;      //p=a
endmodule // cla_add

module cla_incr4(S, G, P, a, cin);
   output [3:0] S;
   output     	 G, P;
   input [3:0]  a;
   input 	    cin;

   wire [3:0] 	 g, p;
   wire [2:0] 	 cout;
   cla_incr incr4[3:0](S, g, p, a, {cout, cin});
   cla_circuit circ(G, P, cout, g, p, cin);
endmodule 

module cla_circuit(G, P, cout, g, p, cin);
   output       G, P;
   output [2:0] cout;
   input [3:0]  g, p;
   input        cin;

   assign P = &p;		// This means "AND" all bits of p
   assign G = g[3] | p[3]&g[2] | p[3]&p[2]&g[1] | p[3]&p[2]&p[1]&g[0] ;
   assign cout[0] = g[0] | p[0]&cin;
   assign cout[1] = g[1] | p[1]&g[0] | p[1]&p[0]&cin;
   assign cout[2] = g[2] | p[2]&g[1] | p[2]&p[1]&g[0] | p[2]&p[1]&p[0]&cin;
endmodule // cla_circuit

module cla_incr16(S, G, P, a, cin);
   output [15:0] S;
   output 	     G, P;
   input [15:0]  a;
   input 	     cin;

   wire [3:0] 	  g, p;
   wire [2:0] 	  cout;

   cla_incr4 add16_0(S[3:0],   g[0], p[0], a[3:0],  cin);
   cla_incr4 add16_1(S[7:4],   g[1], p[1], a[7:4],  cout[0]);
   cla_incr4 add16_2(S[11:8],  g[2], p[2], a[11:8],  cout[1]);
   cla_incr4 add16_3(S[15:12], g[3], p[3], a[15:12], cout[2]);

   cla_circuit circ(G, P, cout, g, p, cin);
endmodule // cla_incr16


module testbench;
   reg  [3:0]  a4;
   reg [15:0]  a16;
   reg 	       a1, cin;
   wire        S1, g1, p1;
   wire [3:0]  S4;
   wire [15:0] S16;

   reg 	      expS1;
   reg [3:0]  expS4;
   reg [15:0] expS16;
   
   integer    i, j;
   integer    pcnt;
   
   cla_incr add1(S1, g1, p1, a1, cin);
   cla_incr4 add4(S4, g1, p1, a4, cin);
   cla_incr16 add16(S16, g1, p1, a16, cin);

   initial
     begin
	     pcnt=0;
        i=16'b1111111111111111; //testing for 1's
        j=0;
	     a16=i;
        
	     cin  = 1;
	     #1;
	     expS16    = (i+j+cin) & ((1<<16)-1);
        if ((expS16===S16))
	       begin
             $display("pass: add16: \n     a=%b, \n     b=%b, cin=%b, \n   S16=%b, \nexpS16=%16b", a16, j, cin, S16, expS16);
          end
         else $display("FAIL");

        i=16'b0000000000000000; //Testing for 0's
        j=0; 
	     a16=i;
	     cin  = 1;
	     #1;
	     expS16    = (i+j+cin) & ((1<<16)-1);
        if ((expS16===S16))
	       begin
             $display("pass: add16: \n     a=%b, \n     b=%b, cin=%b, \n   S16=%b, \nexpS16=%16b", a16, j, cin, S16, expS16);
          end
        else $display("FAIL");
	repeat(20000)		//testing random values of i
	  begin
        i=$random & ((1<<16)-1);
        j=0;
	     a16=i;
	     cin  = 1;
	     #1;
	     expS16    = (i+j+cin) & ((1<<16)-1);
	     if ((expS16===S16))
	       begin
		      pcnt = pcnt+1;
	       end
	     else
	       $display("FAIL: add16: \n     a=%b, \n     b=%b, cin=%b, \n   S16=%b, \nexpS16=%16b", a16, 0, cin, S16, expS16);
	  end // repeat (20)

	$display("Passed %d",pcnt);
	$finish;
     end // initial begin
endmodule // testbench
