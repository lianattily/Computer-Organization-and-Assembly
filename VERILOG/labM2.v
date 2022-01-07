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
    reg clk, enable, expect;
    wire [31:0] z;
    register #(32) mine(z, d, clk, enable);

    initial
    begin
        enable =1;
        clk = 0;
        repeat(20)
        begin
            #2 d = $random%100;
        end
        $finish;		
    end

    always
    begin
            #5 clk = ~clk;
    end 
    
    initial
    begin
            $monitor("%5d: clk=%b,d=%d,z=%d,enable=%d", $time,clk,d,z,enable); 
    end
endmodule 
