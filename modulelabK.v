

module labK;
    reg [31:0] x;
    reg one; //the and of all the bits of x
    reg [1:0] two; //leastsignificant two bits in x
    reg [2:0] three; // concatenation of one and two

    initial         //begins code
    begin
        $display($time, " %b", x);
        x = 0;           //x=[size in bits]['base]value
        $display($time, " %b",x);
        x=x+2;
        $display($time, " %b",x);
        one = &x; // and reduction
        two = x[1:0]; // part-select
        three = {one, two}; // concatenate
        $finish;
    end
endmodule