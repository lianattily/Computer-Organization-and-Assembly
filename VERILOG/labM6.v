//DONE
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
    address = 16'h28; write = 0; read = 0;
    clk=0;
    repeat (11)
    begin
   			#4 read = 1;
            
			if (memOut[6:0] == 7'h33)       //R TYPE
   				#4 $display("%h %h %h %h  %h  %h", memOut[31:25], memOut[24:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);

			if (memOut[6:0] == 7'h6F)       //UJ TYPE  
				#4 $display("%0h %0h %0h", memOut[31:12], memOut[11:7], memOut[6:0]); 

			if (memOut[6:0] == 7'h3 || memOut[6:0] == 7'h13) //I TYPE
                #4 $display("%h %h %h  %h  %h", memOut[31:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]); 

            if (memOut[6:0] == 7'h23)       //S TYPE
                #4 $display("%h %h %h %h  %h  %h", memOut[31:25], memOut[24:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]); 

            if (memOut[6:0] == 7'h63)       //SB-TYPE
				#4 $display("%h %h %h %h  %h  %h", memOut[31:25], memOut[24:20], memOut[19:15], memOut[14:12], memOut[11:7], memOut[6:0]);

			address = address + 4; 
   		end
		$finish;
    end

always
begin
		#4 clk = ~clk;
end

endmodule