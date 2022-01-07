module labK;
reg a,b;
wire notOutput, lowerInput, tmp, z;
not my_not(notOutput, b);
and my_and(z, a, lowerInput);
assign lowerInput = notOutput;


initial
begin
a = 1; b = 1;
$display("a=%b b=%b z=%b", a, b, z);
$finish;
end
endmodule
/*Why did the program fail to capture the output of the circuit? Think about the timing
and make the necessary correction. Compile, and re-run. The correct output should
be 0 because: 1 and (not 1) = 1 and 0 = 0.*/