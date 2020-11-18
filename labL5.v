module yAdder1(z, cout, a, b, cin);     //z= (a xor b) xor cin    |    cout=((a xor b)&cin) or (a&b)
output z, cout;
input a, b, cin;
xor left_xor(tmp, a, b);
xor right_xor(z, cin, tmp);
and left_and(outL, a, b);
and right_and(outR, tmp, cin);
or my_or(cout, outR, outL);
endmodule 

module labL;
integer i, j, k;
reg a,b, cin, expectS;
wire z, cout;
yAdder1 add(z,cout,a,b,cin);
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