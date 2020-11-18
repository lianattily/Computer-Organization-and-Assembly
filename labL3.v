module yMux1(z,a,b,c);
output z;                   //1 bit wire
input a, b, c;              //1 bit wires
wire notC, upper, lower; 
not (notC, c);              //notC=~c
and upperAnd(lower,a,notC);    //lower= a & ~c
and lowerAnd(upper, c,b) ;       //upper=c & b
or (z, upper, lower);            //z= upper | lower
endmodule

module yMux(z, a, b, c);
parameter SIZE=32;        //similar to FINAL in java
output [SIZE-1:0] z;
input [SIZE-1:0] a,b;
input c;
yMux1 mine[SIZE-1:0](z,a,b,c);
endmodule 

module labL;
integer i, j, k;
parameter SIZE=32;
reg [SIZE-1:0]a,b;
reg c;
wire [SIZE-1:0]z;
yMux #(32) my_mux(z,a,b,c);
initial
begin
repeat (10)
begin
 a = $random;
 b = $random;
 c = $random % 2;
 #1;
 if(c===1 && z===b)
        $display("PASS: a=%b  b=%b  c=%b  z=%b", a, b, c, z);
else if(c===0 && z===a) 
        $display("PASS: a=%b  b=%b  c=%b  z=%b", a, b, c, z);
    else 
         $display("FAIL");

end 
$finish;
end
endmodule