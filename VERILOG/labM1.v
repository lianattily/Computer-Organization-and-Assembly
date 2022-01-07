//DONE
module register(z, d, clk, enable);
    parameter n=32;
    input clk, enable;
    input [n-1:0] d;
    reg [n-1:0] q;
    output [n-1:0] z;
    assign z=q;
    always @(posedge clk)begin
       if(enable) q<=d;
    end
endmodule

//vvp a.out +enable=1
module labM;
    reg [31:0] d;
    reg clk, enable, flag;
    wire [31:0] z;
    register #(32) mine(z, d, clk, enable);
    initial
    begin
        flag = $value$plusargs("enable=%b", enable);
        d = 15; clk = 0; #1;
        $display("clk=%b d=%d, z=%d", clk, d, z);
        d = 20; clk = 1; #1;
        $display("clk=%b d=%d, z=%d", clk, d, z);
        d = 25; clk = 0; #1;
        $display("clk=%b d=%d, z=%d", clk, d, z);
        d = 30; clk = 1; #1;
        $display("clk=%b d=%d, z=%d", clk, d, z);
    $finish;
    end
endmodule
