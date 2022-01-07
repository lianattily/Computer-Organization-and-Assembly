//DONE
module mem(memOut, address, memIn, clk, read, write);
    output reg [31:0] memOut;
    input [31:0] address, memIn;
    input clk, read, write;
    reg [31:0] MEM[0:1023];             

    always @(posedge clk) 
    begin
        if(write) MEM[address]=memIn;                   //write into address but wheres the data?
        if(read) memOut=MEM[address];       //read data at address
    end
endmodule

module labM;
    wire [31:0] memOut;
    reg [31:0] address, memIn;
    reg clk, read, write;
    mem data(memOut, address, memIn, clk, read, write);
    initial
    begin
        write = 1; read = 0; address = 16;      //write at address 16
		clk = 0;
		memIn = 32'h12345678;
		#4 read = 1; 
		#1 $display("Address %d contains %h", address, memOut); 
		address = address + 4; 
		#4 read = 0; write=1; address=24;       //write at address 24
		memIn = 32'h89abcdef;
		#4 read = 1;
		#1 $display("Address %d contains %h", address, memOut); 
		#4;
        write = 0; read = 1; address = 16;      //start reading from address 16, incrementing 4 for address at a time
        repeat (3)
        begin
            #1 $display("Address %d contains %h", address, memOut);
            address = address + 4;
        end
    $finish;
    end

    always
    begin
            #4 clk = ~clk;
    end
endmodule