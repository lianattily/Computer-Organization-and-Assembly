module rm(z, a, b);
output z;
input[1:0] a,b;

and (al, a[0], a[1]);
and (be, b[0], b[1]);
or (z, al, be);

endmodule

