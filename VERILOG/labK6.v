module labK;

reg a,b,c;
wire tmp, tmp2,tmp3,z,half;
not my_not(tmp2, c);        //tmp2=~c
and second(tmp3, tmp1, a);
assign half=tmp3;

and my_and(tmp,b,c);    //tmp = b&c
or my_or(z,tmp3,tmp2);
assign z=z;
initial
begin
    a = 1; b = 0; c = 0;
    #1 $display("(a&~c) OR (b&c) z=%b", z);
end
endmodule