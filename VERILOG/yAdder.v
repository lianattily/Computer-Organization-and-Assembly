module yAdder(z, cout, a, b, cin);
parameter SIZE=32;
output [SIZE-1:0] z;
output cout;
input [SIZE-1:0] a, b;
input cin;
wire[SIZE-1:0] in, out;
yAdder1 mine[SIZE:0](z, out, a, b, in);
assign in[0] = cin;
assign in[SIZE-1:1] = out[SIZE-2:0]; 
assign cout=out[SIZE-1];

endmodule