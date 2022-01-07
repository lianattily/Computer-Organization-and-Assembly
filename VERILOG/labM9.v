
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

module register(z, clk, d, enable);
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

module rf(RD1,RD2, RN1,RN2, WN,WD, clk, W);
/****************************
Behavioral register file
Written by H. Roumani, 2009
****************************/
parameter DEBUG = 0;

input clk, W;
input [4:0] RN1, RN2, WN;
input [31:0] WD;
output [31:0] RD1, RD2;

reg [31:0] RD1, RD2;
reg [31:0] arr [1:31];

always @(RN1 or arr[RN1])
	if (RN1 == 0)
		RD1 = 0;
	else
	begin
		RD1 = arr[RN1];
		if (DEBUG != 0) $display("RF: read %0dd from reg#%0d", RD1, RN1);
	end

always @(RN2 or arr[RN2])
	if (RN2 == 0)
		RD2 = 0;
	else
	begin
		RD2 = arr[RN2];
		if (DEBUG != 0) $display("RF: read %0dd from reg#%0d", RD2, RN2);
	end


always @(posedge clk)
	if (W == 1 && WN != 0)
	begin
		arr[WN] = WD;
		if (DEBUG != 0) $display("RF: wrote %0dd to reg#%0d", WD, WN);
	end

endmodule

module yIF(ins, PCp4, PCin, clk);
    input [31:0] PCin;
    input clk;
    output [31:0] ins, PCp4;
    wire [31:0] pcOut;
    register PC(pcOut, clk, PCin, 1'b1);
    yAlu myAlu(PCp4, null, pcOut, 32'd4, 3'b010);       //PCp4=PCout+4
    mem myMem(ins, pcOut, 32'b0, clk, 1'b1, 1'b0);      //fetch instruction address from memory

endmodule

//extracts the various fields of ins and looks up the needed registers.
module yID(rd1, rd2, immOut, jTarget, branch, ins, wd, RegWrite, clk); 
    output [31:0] rd1, rd2, immOut;
    output [31:0] jTarget;
    output [31:0] branch;
    input [31:0] ins, wd;
    input RegWrite, clk;
    wire [19:0] zeros, ones; // For I-Type and SB-Type
    wire [11:0] zerosj, onesj; // For UJ-Type
    wire [31:0] imm, saveImm; // For S-Type
    rf myRF(rd1, rd2, ins[19:15], ins[24:20], ins[11:7], wd, clk, RegWrite);
    assign imm[11:0] = ins[31:20];
    assign zeros = 20'h00000;
    assign ones = 20'hFFFFF;
    yMux #(20) se(imm[31:12], zeros, ones, ins[31]);
    assign saveImm[11:5] = ins[31:25];
    assign saveImm[4:0] = ins[11:7];
    yMux #(20) saveImmSe(saveImm[31:12], zeros, ones, ins[31]);
    yMux #(32) immSelection(immOut, imm, saveImm, ins[5]);
    assign branch[11] = ins[31];
    assign branch[10] = ins[7];
    assign branch[9:4] = ins[30:25];
    assign branch[3:0] = ins[11:8];
    yMux #(20) bra(branch[31:12], zeros, ones, ins[31]);
    assign zerosj = 12'h000;
    assign onesj = 12'hFFF;
    assign jTarget[19] = ins[31];
    assign jTarget[18:11] = ins[19:12];
    assign jTarget[10] = ins[20];
    assign jTarget[9:0] = ins[30:21];
    yMux #(12) jum(jTarget[31:20], zerosj, onesj, jTarget[19]);
endmodule

module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);
    output [31:0] z;
    output zero;
    input [31:0] rd1, rd2, imm;
    input [2:0] op;
    input ALUSrc;

    wire [31:0] b;
    
    yMux #(32) pick(b, rd2, imm, ALUSrc);
    yAlu oop(z, zero, rd1, b, op);

endmodule

module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
    output [31:0] memOut;
    input [31:0] exeOut, rd2;
    input clk, MemRead, MemWrite;
    mem DM(memOut, exeOut, rd2, clk, MemRead, MemWrite); 
endmodule


module yWB(wb, exeOut, memOut, Mem2Reg);
    output [31:0] wb;
    input [31:0] exeOut, memOut;
    input Mem2Reg;
    yMux #(32) WB(wb, exeOut, memOut, Mem2Reg);
endmodule

//ALUsrc =0 rs2   =1 imm
module labM;
    reg [31:0] PCin;
    reg RegWrite, clk, ALUSrc; 
    reg [2:0] op;
    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, branch;
    wire [31:0] memOut, wb;
    reg Mem2Reg, MemRead, MemWrite;
    wire [31:0] jTarget;
    wire zero;

    yIF myIF(ins, PCp4, PCin, clk);
    yID myID(rd1, rd2, imm, jTarget, branch, ins, wd, RegWrite, clk);
    yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
    yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
    yWB myWB(wb, z, memOut, Mem2Reg);
    assign wd = wb;

    initial
    begin
    //------------------------------------Entry point
    PCin = 16'h28;
    //------------------------------------Run program
    repeat (11)
    begin
    //---------------------------------Fetch an ins
    clk = 1; #1;
    op = 3'b010;
    //---------------------------------Set control signals
   if (ins[6:0] == 7'h33) // R-Type
    begin
        RegWrite = 1; ALUSrc = 0;   //ALUSrc=0   means use rs2 
        MemRead = 0;
		MemWrite = 0;
		Mem2Reg=0;//Mem2Reg = 1;
        if (ins[14:12] == 3'b110)   // funct3 = or
            begin
                op = 3'b001;
            end
        else if (ins[14:12] == 3'b000) begin
                 op = 3'b010;           // funct3 = add
            end
    end

  /*  if(ins[6:0]==7'h6F) // UJ-Type
    begin
        RegWrite = 1; ALUSrc = 1;   
        MemRead = 0;
		MemWrite = 0;
		Mem2Reg = 0;
    end*/
    
    if (ins[6:0] === 7'h3) // lw
        begin
            RegWrite = 1; 
            ALUSrc = 1; 
            MemRead=1; 
            MemWrite=0; 
            Mem2Reg=1;
        end 
    
    else if (ins[6:0] === 7'h13) //addi
        begin
            RegWrite = 1; 
            ALUSrc = 1; 
            MemRead=0;
            MemWrite=0; 
            Mem2Reg=1;
        end


    if (ins[6:0] == 7'h23)       //S TYPE
    begin
        RegWrite = 0; 
        ALUSrc = 1;
        MemRead = 0;
		MemWrite = 1;
		Mem2Reg = 0;
    end

    if (ins[6:0] == 7'h63)       //SB-TYPE beq
    begin
        RegWrite = 0; 
        ALUSrc = 0;
        MemRead = 0;
		MemWrite = 0;
		Mem2Reg = 0;
    end
    // Add statements to adjust the above defaults
    //---------------------------------Execute the ins
    clk = 0; #1;
    //---------------------------------View results
    #5 $display("%h: rd1=%2d rd2=%2d z=%3d zero=%b wb=%2d", ins, rd1, rd2, z, zero, wb);
    //---------------------------------Prepare for the next ins
    #1 PCin = PCp4;
    end
    $finish;
    end
    
endmodule