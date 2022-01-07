module yMux(z, a, b, c);
parameter SIZE=32;        //similar to FINAL in java
output [SIZE-1:0] z;
input [SIZE-1:0] a,b;
input c;
yMux1 mine[SIZE-1:0](z,a,b,c);
endmodule 

module yMux1(z,a,b,c);
output z;                   //1 bit wire
input a, b, c;              //1 bit wires
wire notC, upper, lower; 
not (notC, c);              //notC=~c
and upperAnd(lower,a,notC);    //lower= a & ~c
and lowerAnd(upper, c,b) ;       //upper=c & b
or (z, upper, lower);            //z= upper | lower
endmodule

module yMux4to1(z, a0,a1,a2,a3, c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a0, a1, a2, a3;
input [1:0] c;
wire [SIZE-1:0] zLo, zHi;
yMux #(SIZE) lo(zLo, a0, a1, c[0]);
yMux #(SIZE) hi(zHi, a2, a3, c[0]);
yMux #(SIZE) final(z, zLo, zHi, c[1]);
endmodule 

module labL;
integer i, j, k;
parameter SIZE=32;
reg [SIZE-1:0]a,b;
reg c;
wire [SIZE-1:0]z;
yMux4to1 #(32) my_mux(z,a,b,c);
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