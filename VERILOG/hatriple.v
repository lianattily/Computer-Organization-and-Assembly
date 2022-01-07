module hadd1(S, Cout, a, b);
   output S, Cout;
   input  a, b;

   assign S    = a^b;
   assign Cout = a&b;
endmodule // hadd1

module hadd2(S, Cout, a, b);
   output S, Cout;
   input  a, b;

   xor (S, a, b);
   and (Cout, a, b);
endmodule // hadd1

module hadd3(S, Cout, a, b);
   output reg S, Cout;
   input  a, b;

   always @(a,b)
     begin
	S    = a^b;
	Cout = a&b;
     end
endmodule // hadd1

module testbench;
   reg a, b;
   wire S, Cout;
   integer i, j, tmp;
   reg 	   expS, expCout;	// Values expected is module works OK.

   hadd3 add3(S, Cout, a, b);
   initial
     begin
	$display("-----------------------------------------------------");
	for (i=0; i<2; i=i+1)
	  for (j=0; j<2; j=j+1)
	    begin
	       a   = i;
	       b   = j;
	       #1;
	       expS    = (i+j)%2;  // The %2 is not really needed 
	       expCout = (i+j)>>1; // i, j have to be integers
	       if (expS===S)
		 $display("PASS: A=%b, B=%b, S=%b, Cout=%b", a, b, S, Cout);
	       else
		 $display("FAIL: A=%b, B=%b, S=%b, Cout=%b, expS=%b", a, b, S, Cout, expS);
	       if (expCout===Cout)
		 $display("PASS: A=%b, B=%b, S=%b, Cout=%b", a, b, S, Cout);
	       else
		 $display("FAIL: A=%b, B=%b, S=%b, Cout=%b, expCout=%b", a, b, S, Cout, expCout);
	       $display("-----------------------------------------------------");
	    end // for (j=0; j<2; j=j+1)
	$finish;
     end // initial begin
endmodule // testbench
