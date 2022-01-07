//first= a xor b   , second=  a and b ,   z= Cin xor first, Cout = (Cin and first) OR second
module labK;
reg a,b, Cin;
wire xor1, andAB, z, Cout,tmp;

xor my_xor(xor1, a,b);      //first
and my_and(andAB, a,b);     //second
xor my_Z(z, Cin, xor1);     //z
and my(tmp,Cin, xor1);       //Cin and first
or my_or(Cout, tmp, andAB);

initial
begin
    a = 1; b = 0; Cin = 0;
    #1 $display("Cout=%b", Cout);
     $display("z=%b", z);
end
endmodule