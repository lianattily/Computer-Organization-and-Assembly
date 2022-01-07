module mem(memOut, address, memIn, clk, read, write);
/* ***************************
Behavioral Memory Unit.
Written by H. Roumani, 2009.
*************************** */

parameter DEBUG = 0;

parameter CAPACITY = 16'hffff;
input clk, read, write;
input [31:0] address, memIn;
output [31:0] memOut;
reg [31:0] memOut;
reg [31:0] arr [0:CAPACITY];
reg fresh = 1;

always @(read or address or arr[address])
begin
	if (fresh == 1)
	begin
		fresh = 0;
		$readmemh("ram.dat", arr);
	end

	if (read == 1)
	begin
		if (address[1:0] != 2'b00)
		begin
			//$display("Unaligned Load Address %d", address); 
			memOut = 32'hxxxxxxxx;
		end
		else if (address > CAPACITY)
		begin
			//$display("Address %h out of range %d", address, CAPACITY);
			memOut = 32'hxxxxxxxx;
		end
		else
		begin
			memOut = arr[address];
		end
	end
end

always @(posedge clk)
begin
	if (write == 1)
	begin
		if (address[1:0] != 2'b00)
		begin
			//$display("Unaligned Store Address %d", address);
		end
		else if (address > CAPACITY)
		begin
			$display("Address %d out of range %d", address, CAPACITY);
		end
		else
		begin
			arr[address] <= memIn;
			if (DEBUG != 0) $display("MEM: wrote %0dd at address %0dd", memIn, address);
		end
	end
end

endmodule



module labM;
    reg clk, read, write;
    reg [31:0] address, memIn;
    wire [31:0] memOut;
    mem data(memOut, address, memIn, clk, read, write);

    initial
    begin
    address = 16'h28; write = 0; read = 1;
    clk=0;
    repeat (11)
    begin
            #1 read = 1;
            #1 clk = 1;
            #1 clk = 0;
   			#1 $display("Address %d contains %h", address, memOut); 
			address = address + 4; 
   		end
		$finish;
    end
endmodule