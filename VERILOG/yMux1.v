module yMux1(z,a,b,c);
output z;                   //1 bit wire
input a, b, c;              //1 bit wires
wire notC, upper, lower; 
not (notC, c);              //notC=~c
and upperAnd(lower,a,notC);    //lower= a & ~c
and lowerAnd(upper, c,b) ;       //upper=c & b
or (z, upper, lower);            //z= upper | lower

endmodule