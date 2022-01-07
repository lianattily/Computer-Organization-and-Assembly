/*Lian Attily   |   November 5th, 2020  |   LABK
A module that implements a two-bit comparator*/

module labK;
    integer i, j;
    reg [1:0]a,b;                           //two-bit register
    reg expectG,expectE;                    //one bit register for comparasions
    wire GR,EQ;                             //one bit wire
    wire [1:0] Gr, Eq;                    //two-bit wire

    assign Eq=(a&b) | (~a&~b);              //Eq = ab + a'b' = 
    assign EQ= Eq[1] & Eq[0];                //EQ = Eq1 Eq0


    assign Gr=a&~b;                         //Gr1= ab'
    assign GR= Gr[1] | (Eq[1] & Gr[0]);   //GR = Gr1 + Eq1 Gr0

initial
begin
    for (i = 0; i < 4; i = i + 1)
    begin
        for (j = 0; j < 4; j = j + 1)
        begin
            a = i; b = j; 
            #1 //wait
            expectG=(a>b);
            expectE=(a==b); 
            if(expectG===GR && expectE==EQ)
                $display("PASS a=%b b=%b -> Gr=%b, Eq=%b", a, b, GR, EQ);
            else 
                $display("FAIL a=%b b=%b -> Gr=%b, Eq=%b", a, b, GR, EQ);
         end
    end
 $finish;
end
endmodule