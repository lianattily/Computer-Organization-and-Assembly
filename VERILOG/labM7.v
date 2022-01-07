//DONE
module yMux(z, a, b, c);
    parameter SIZE=32;        //similar to FINAL in java
    output [SIZE-1:0] z;
    input [SIZE-1:0] a,b;
    input c;
    yMux1 mine[SIZE-1:0](z,a,b,c);
endmodule 

module yMux1(z,a,b,c);
    output z;                   //1 bit wire
    input a, b, c;              //1 bit wires
    wire notC, upper, lower; 
    not (notC, c);              //notC=~c
    and upperAnd(lower,a,notC);    //lower= a & ~c
    and lowerAnd(upper, c,b) ;       //upper=c & b
    or (z, upper, lower);            //z= upper | lower
endmodule

module yMux4to1(z, a0,a1,a2,a3, c);
    parameter SIZE = 2;
    output [SIZE-1:0] z;
    input [SIZE-1:0] a0, a1, a2, a3;
    input [1:0] c;
    wire [SIZE-1:0] zLo, zHi;
    yMux #(SIZE) lo(zLo, a0, a1, c[0]);
    yMux #(SIZE) hi(zHi, a2, a3, c[0]);
    yMux #(SIZE) final(z, zLo, zHi, c[1]);
endmodule 

module yAdder1(z, cout, a, b, cin);     //z= (a xor b) xor cin    |    cout=((a xor b)&cin) or (a&b)
    output z, cout;
    input a, b, cin;
    xor left_xor(tmp, a, b);
    xor right_xor(z, cin, tmp);
    and left_and(outL, a, b);
    and right_and(outR, tmp, cin);
    or my_or(cout, outR, outL);
endmodule 

module yAdder(z, cout, a, b, cin);
    parameter SIZE=2;
    output [SIZE-1:0] z;
    output cout;
    input [SIZE-1:0] a, b;
    input cin;
    wire[SIZE-1:0] in, out;
    yAdder1 mine[SIZE-1:0](z, out, a, b, in);
    assign in[0] = cin;
    assign in[SIZE-1:1] = out[SIZE-2:0]; 
    assign cout=out[SIZE-1];
endmodule

module yArith(z, cout, a, b, ctrl);
    output [31:0] z;
    output cout;
    input [31:0] a, b;
    input ctrl;
    wire [31:0] notB, tmp;
    wire cin;
    assign cin=ctrl;
    not NOTB[31:0] (notB, b);
    yMux #(32) mux(tmp, b, notB, cin);
    yAdder #(32)adder(z, cout, a, tmp, cin);
endmodule 

module yAlu(z, ex, a, b, op); 
    input [31:0] a, b; 
    input [2:0] op; 
    output [31:0] z; 
    output ex; 
    wire [31:0] andi, ori, arith, sub, slt;
    wire condition;
    assign slt[31:1] = 0;  
    wire [15:0] z16;
    wire [7:0]  z8;
    wire [3:0]  z4;
    wire [1:0]  z2;
    wire z1;
    //and-----------------------------------------
    and myAnd[31:0](andi, a, b);

    //or------------------------------------------
    or  myOr[31:0](ori, a, b);
    
    //(+-)----------------------------------------
    yArith myArith(arith,null, a, b, op[2]);

    //slt-----------------------------------------
    xor myXor (condition, a[31], b[31]);
    yArith sltArith(sub,null, a, b, 1'b1);
    yMux1  sltMux (slt[0], sub[31], a[31], condition);

    //---------------------------------------------
    //z=operation based on op
    yMux4to1 #(32) myMux (z, andi, ori, arith, slt, op[1:0]);

    //exception-----------------------------------------
    or or16[15:0] (z16, z[15:0], z[31:16]); 
    or or8[7:0]  (z8, z16[7:0], z16[15:8]); 
    or or4[3:0] (z4, z8[3:0], z8[7:4]); 
    or or2[1:0]  (z2, z4[1:0], z4[3:2]); 
    or or1 (z1, z2[0:0], z2[1:1]);
    not noting(ex, z1);

endmodule

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

module yIF(ins, PCp4, PCin, clk);
    input [31:0] PCin;
    input clk;
    output [31:0] ins, PCp4;
    wire [31:0] pcOut;
    register #(32) PC(pcOut, PCin, clk, 1'b1);
    yAlu myAlu(PCp4, null, pcOut, 32'd4, 3'b010);       //PCp4=PCout+4
    mem myMem(ins, pcOut, 32'b0, clk, 1'b1, 1'b0);      //fetch instruction address from memory

endmodule

module labM;
    reg [31:0] PCin;
    reg clk;
    wire [31:0] ins, PCp4;
    yIF myIF(ins, PCp4, PCin, clk);

    initial
    begin
        //------------------------------------Entry point
        PCin = 16'h28;
        //------------------------------------Run program
        repeat (11)
        begin
        //---------------------------------Fetch an ins
        clk = 1; #1;
        //---------------------------------Execute the ins
        clk = 0; #1;
        //---------------------------------View results
        #5 $display("instruction = %h", ins);
        // Add a statement to prepare for the next instruction
        PCin=PCp4;
        end
    $finish;
    end
endmodule