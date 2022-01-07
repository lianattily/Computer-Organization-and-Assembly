module H_Adder(S, Cout, A,B);
    output reg S, Cout;
    input A,B;
    //xor = (A&B')+(B&A')
    always @(A, B)
    begin
        assign S=A^B;
        assign Cout=A&B;
    end

endmodule

module DFF(D, clk, Q, Qb);
  input D, clk;
  output reg Q;
  output Qb;
  assign Qb=~Q;
  always @(posedge clk)
  begin
    Q<=D;
  end

endmodule

module F_adder(S, Cout, A, B, Cin);
    output S, Cout;
    input A, B, Cin;

   // S=(A^B)^Cin)  Cout=(Cin&(A^B))OR(A&B)
   assign S=(A^B)^Cin;
   assign Cout=(Cin&(A^B))|(A&B);

endmodule


module xor3(D, A, B, C);
  output D;
  input A,B,C;

  xor (AxB, A,B);
  xor (D, AxB, C);

endmodule

module testbench;
   reg a, b,c;
   wire S, d, Cout;
   integer i, j, k, tmp;
   reg 	   expS, expCout, Cin;	// Values expected is module works OK.

   //F_adder add(S, Cout, a, b, Cin);
  // H_Adder add2(S, Cout, a, b);
  xor3 x(d,a,b,c);
   initial
     begin
	$display("-----------------------------------------------------");
	for (i=0; i<2; i=i+1)
	  for (j=0; j<2; j=j+1)
    for(k=0;k<2;k=k+1)
	    begin
	       a   = i;
	       b   = j;
         c= k;
           Cin = 0;
	       #1;
	       expS    = a^b^c;//(i+j)%2;  // The %2 is not really needed 
	      // expCout = (i+j)>>1; // i, j have to be integers
	       if (expS===d)
		 $display("PASS: A=%b, B=%b, c=%b, d=%b", a, b, c, d);
	       else
		 $display("FAIL: A=%b, B=%b, S=%b, Cout=%b, expS=%b", a, b, S, Cout, expS);
	 //      if (expCout===Cout)
	//	 $display("PASS: A=%b, B=%b, S=%b, Cout=%b", a, b, S, Cout);
//	       else
	//	 $display("FAIL: A=%b, B=%b, S=%b, Cout=%b, expCout=%b", a, b, S, Cout, expCout);
	       $display("-----------------------------------------------------");
	    end // for (j=0; j<2; j=j+1)
	$finish;
     end // initial begin
endmodule // testbench
