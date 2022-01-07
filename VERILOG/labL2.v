module yMux1(z,a,b,c);
output z;                   //1 bit wire
input a, b, c;              //1 bit wires
wire notC, upper, lower; 
not (notC, c);              //notC=~c
and upperAnd(lower,a,notC);    //lower= a & ~c
and lowerAnd(upper, c,b) ;       //upper=c & b
or (z, upper, lower);            //z= upper | lower

endmodule

module yMux2(z, a, b, c);

output [1:0] z;
input [1:0] a,b;
input c;
yMux1 upper(z[0], a[0], b[0], c);
yMux1 lower(z[1], a[1], b[1],c);

endmodule 

module labL;
integer i, j, k;
reg [1:0]a,b, expectS;
reg c;
wire [1:0]z;
yMux2 mine(z,a,b,c);
initial
begin
for (i = 0; i < 4; i = i + 1)
    begin
        for (j = 0; j < 4; j = j + 1)
        begin
            for(k=0; k < 2; k = k + 1)
            begin
                a = i; b = j; c = k;
                expectS=c===1?b:a;  //(a+b+c)&3;
                 #1 
                 if(expectS===z)
                 $display("a=%b b=%b c=%b z=%b", a, b,c, z);
            end
         end
    end
    $finish;
end
endmodule