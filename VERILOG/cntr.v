module incr(o,i);
   output reg [3:0] o;
   input [3:0] 	    i;

   always @(i)
     o = i+1;
endmodule // incr

module cntr(o, c, pulse);
   output reg [3:0] o;
   input 	    c, pulse;
   wire [3:0] 	    tmp;
   
   incr myincr(tmp, o);
   
   initial
     o=0;

   always @(posedge pulse)
     if (c)
       o <= tmp;

endmodule // cntr

module testbed;
   reg pulse;
   reg c;
   wire [3:0] o;

   cntr mycntr(o, c, pulse);
   
   initial
     begin
	c = 0;
	pulse = 0;
	
	repeat (35)
	  begin
	     #5 pulse = ~pulse;
	     #1 $display("cntr = %h",o);
	  end
	$finish;
     end
endmodule // testbed
