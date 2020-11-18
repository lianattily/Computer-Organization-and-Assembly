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
parameter SIZE=2;
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

module labL;
parameter SIZE=32;
integer i, j, k;
reg [SIZE-1:0]a,b, expectS;
reg cin;
wire [SIZE-1:0]z;
wire cout;
yAdder #(.SIZE(32))add(z,cout,a,b,cin);
initial
begin
    for (i = 0; i < 4; i = i + 1)
    begin
        for (j = 0; j < 4; j = j + 1)
        begin
            for(k=0; k < 2; k = k + 1)
            begin
                a = i; b = j; cin = k;
                expectS=(a+b+cin);  //(a+b+c)&3;
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