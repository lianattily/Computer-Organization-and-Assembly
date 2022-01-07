//16-bit adder requires 5 CLA circuits (4 plus 1)
//four 4-bit adders each containing 4 full-adders and a CLA circuit

module cla_add(S, g, p, a, b, cin);     //no cout
    output S, g, p;
    input a, b, cin;

    assign s=a^b^cin;
    assign g=a&b;
    assign p= a|b;
endmodule

module cla_cricuit(G, P, cout, g, p, cin);
    output G, P;
    output [2:0] cout;
    input [3:0] g, p;
    input  cin;

    assign P=&p;        //takes & of all bits inside p
    assign G= g[3] | p[3]&g[2] | p[3]&p[2]&p[1] | p[3]&p[2]&p[1]&g[0];
    assign cout[0]= g[0] | p[0]&cin;
    assign cout[1]= g[1] | p[1]&g[0] | p[1]&p[0]&cin;
    assign cout[2]= g[2] | p[2]&g[1] | p[2]&p[1]&g[0] | p[2]&p[1]&p[0]&cin;
endmodule

module cla_add4(S, G, P, a, b, cin);
    output [3:0] S;
    output G, P;
    input [3:0] a,b;
    input cin;

    wire [3:0] g, p;
    wire [2:0] cout;
    //we only need to instantiate 4+1 modules according to cla_add4.pdf
    cla_add add4[3:0](S, g, p, a ,b, {cout, cin});
    cla_cricuit circ(G, P, cout, g, p, cin);
endmodule

module cla_add16(S,G,P,a,b,cin);
    output [15:0] S;
    output G,P;
    input [15:0] a, b;
    input cin;

    wire[3:0] g, p;
    wire [2:0] cout;

    cla_add4 add16_0(S[3:0],  g[0],  p[0],  a[3:0],  b[3:0],  cin);
    cla_add4 add16_1(S[7:4],  g[1],  p[1],  a[7:4],  b[7:4],  cout[0]);
    cla_add4 add16_1(S[11:8],  g[2],  p[2],  a[11:8],  b[11:8],  cout[1]);
    cla_add4 add16_1(S[15:12],  g[3],  p[3],  a[15:12],  b[15:12],  cout[2]);
endmodule

module testbench;
    reg [3:0]   a4, b4;
    reg [15:0]  a16, b16;
    reg         a1, b1, cin;
    wire        S1, g1, p1;
    wire [3:0]  S4;
    wire [15:0] S16;

    reg         expS1;
    reg [3:0]   expS4;
    reg [15:0]  expS16;

    integer i, j;
    integer pcnt;

    cla_add add1(S1, g1, a1, b1, cin);
    cla_add4 add4(S4, g1, p1, a4, b4, cin);
    cla_add16 add16(S16, g1, p1, a16, b16, cin);
    

    for(i=)
endmodule