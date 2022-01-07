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

module yAdder1(z, cout, a, b, cin);     //z= (a xor b) xor cin    |    cout=((a xor b)&cin) or (a&b)
output z, cout;
input a, b, cin;
xor left_xor(tmp, a, b);
xor right_xor(z, cin, tmp);
and left_and(outL, a, b);
and right_and(outR, tmp, cin);
or my_or(cout, outR, outL);
endmodule 

module yAdder(z, cout, a, b, cin);
parameter SIZE=32;
output [SIZE-1:0] z;
output cout;
input [SIZE-1:0] a, b;
input cin;
wire[SIZE-1:0] in, out;
yAdder1 mine[SIZE-1:0](z, out, a, b, in);
assign in[0] = cin;
assign in[SIZE-1:1] = out[SIZE-2:0]; 
assign cout=out[SIZE-1];
endmodule

module yArith(z, cout, a, b, ctrl);
// add if ctrl=0, subtract if ctrl=1
output [31:0] z;
output cout;
input [31:0] a, b;
input ctrl;
wire [31:0] notB, tmp;
wire cin;
assign cin=ctrl;
not NOTB[31:0] (notB, b);
yMux #(32) mux(tmp, b, notB, cin);
yAdder adder(z, cout, a, tmp, cin);
endmodule 

module labL;
parameter SIZE=32;
integer i, j, k;
reg signed [SIZE-1:0] a, b, expectS; 
reg signed ctrl; 
wire signed [31:0] z; 
wire signed cout, cin;
yArith arith(z, cout, a, b, ctrl); 
initial
begin
    for (i = 0; i < 4; i = i + 1)
    begin
        for (j = 0; j < 4; j = j + 1)
        begin
            for(k=0; k < 2; k = k + 1)
            begin
                a = i; b = j; ctrl = k;
                expectS = ctrl ? (a-b) : (a+b);
                 #1 
                 if(expectS===z)
                 $display("PASS a=%b b=%b cin=%b z=%b", a, b,cin, z);
                 else $display("FAIL");
            end
         end
    end
    $finish;
end
endmodule