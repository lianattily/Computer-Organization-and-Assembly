module labK;

reg a,b,c, flag, expect;
wire tmp, tmp2,tmp3,z;
not my_not(tmp2, c);        //tmp2=~c
and second(tmp3, tmp1, a);

and my_and(tmp,b,c);    //tmp = b&c

or my_or(z,tmp3,tmp2);
initial
begin
    
    flag = $value$plusargs("a=%b", a);
    flag = $value$plusargs("b=%b", b);
    flag = $value$plusargs("c=%b", c);
    #1
    expect=(a&~c)|(b&c);
    $display("Expect = %b", expect);
    if(expect===flag)$display("PASS (a&~c) OR (b&c) z=%b", z);
    else $display("FAIL (a&~c) OR (b&c) z=%b", z);
end
endmodule