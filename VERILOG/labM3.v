module rf(rd1, rd2, rs1, rs2, wn, wd, clk, w);
    input [4:0] rs1, rs2, wn;      //5 bit 
    input [31:0] wd;
    input clk, w;
    output [31:0] rd1, rd2;
    reg [31:0] rf[31:0];            //32, 32-bit registers

    assign rd1=rf[rs1];
    assign rd2=rf[rs2];

    always @(posedge clk)
        if(w) rf[wn]<= wd;      //if w=1, write wd (data) into register # wn 

endmodule

module labM;
    reg [4:0] rs1, rs2;
    reg [4:0] wn;      //5 bit 
    reg [31:0] wd;
    reg clk, w, flag, i;
    wire [31:0] rd1, rd2;
    rf myRF(rd1, rd2, rs1, rs2, wn, wd, clk, w);

    initial
    begin
        //flag = $value$plusargs("w=%b", w);
        w=1;
        for (i = 0; i < 32; i = i + 1)
        begin
        clk = 0;
        wd = i * i;
        wn = i;
        clk = 1;
        #1;
        end
    end

    initial
    repeat(10)
    begin
        rs1 = $random%32;
        rs2 = $random%32;
        #5 $display(" rs1 ==> %0d\n rs2 ==> %0d\n rd1 ==> %0d\n rd2 ==> %0d\n", rs1, rs2, rd1, rd2);	
    end
    always
    begin
            #1 clk = ~clk;
    end 
endmodule