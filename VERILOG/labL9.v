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

module yAlu(z, ex, a, b, op); 
    input [31:0] a, b; 
    input [2:0] op; 
    output [31:0] z; 
    output ex; 
    wire [31:0] andi, ori, arith, sub, slt;
    wire condition;
    assign slt[31:1] = 0;  
    
    //and-----------------------------------------
    and myAnd[31:0](andi, a, b);
    //or------------------------------------------
    or  myOr[31:0](ori, a, b);
    
    //(+-)----------------------------------------
    yArith myArith(arith,null, a, b, op[2]);
    //---------------------------------------------
    //z=operation based on op
    yMux4to1 #(32) myMux (z, andi, ori, arith, slt, op[1:0]);
endmodule

module labL;
    reg signed ctrl; 
    wire signed cout, cin;
    reg [31:0] a, b;
    reg [31:0] expect;
    reg [2:0] op;
    wire ex;
    wire [31:0] z;
    reg ok, flag;
    yAlu mine(z, ex, a, b, op);

    initial
    begin
    repeat (10)
    begin
        a = $random%100;
        b = $random%100;

        op=$random%3;
        if(op === 3'b000)
            expect = a&b;
        if(op === 3'b001)
            expect = a|b;
        if(op === 3'b010)
            expect = a+b;
        if(op === 3'b110)
            expect = a-b;
        
        #1;  
        if(expect===z)
        $display("z=%b", z);
        else $display("FAIL");
    end
    $finish;
    end
endmodule 