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

module yIF(ins, PC, PCp4, PCin, clk);
    output [31:0] ins, PC, PCp4;
    input [31:0] PCin;
    input clk;
    wire zero;
    wire read, write, enable;
    wire [31:0] a, memIn;
    wire [2:0] op;
    register #(32) pcReg(PC,clk, PCin, enable);
    mem insMem(ins, PC, memIn, clk, read, write);
    yAlu myAlu(PCp4, zero, a, PC, op);
    assign enable = 1'b1;
    assign a = 32'h0004;
    assign op = 3'b010;
    assign read = 1'b1;
    assign write = 1'b0;
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

//DONE
module yPC(PCin, PC, PCp4,INT,entryPoint,branchImm,jImm,zero,isbranch,isjump);
    output [31:0] PCin;
    input [31:0] PC, PCp4, entryPoint, branchImm;
    input [31:0] jImm;
    input INT, zero, isbranch, isjump;
    wire [31:0] branchImmX4, jImmX4, jImmX4PPCp4, bTarget, choiceA, choiceB;
    wire doBranch, zf;
    // Shifting left branchImm twice
    assign branchImmX4[31:2] = branchImm[29:0];
    assign branchImmX4[1:0] = 2'b00;
    // Shifting left jump twice
    assign jImmX4[31:2] = jImm[29:0];
    assign jImmX4[1:0] = 2'b00;
    // adding PC to shifted twice, branchImm
    yAlu bALU(bTarget, zf, PC, branchImmX4, 3'b010);  //PC not PCp4
    // adding PC to shifted twice, jImm
    yAlu jALU(jImmX4PPCp4, zf, PC, jImmX4, 3'b010);  
    // deciding to do branch
    and (doBranch, isbranch, zero);
    yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);
    yMux #(32) mux2(choiceB, choiceA, jImmX4PPCp4, isjump);
    yMux #(32) mux3(PCin, choiceB, entryPoint, INT);
endmodule

module yC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
    output isStype, isRtype, isItype, isLw, isjump, isbranch;
    input [6:0] opCode;
    wire lwor, ISselect, JBselect, sbz, sz;
    // opCode
    // lw 0000011
    // I-Type 0010011 
    // R-Type 0110011
    // SB-Type 1100011
    // UJ-Type 1101111
    // S-Type 0100011
    // Detect UJ-type
    assign isjump=opCode[3];
    // Detect lw
    or (lwor, opCode[6], opCode[5], opCode[4], opCode[3], opCode[2]);   //00000
    not (isLw, lwor);
    // Select between S-Type and I-Type
    xor (ISselect, opCode[0], opCode[1], opCode[2], opCode[3], opCode[6]);  
    and (isStype, ISselect, opCode[4]); 
    and (isItype, ISselect, opCode[5]); 
    // Detect R-Type
    and (isRtype, opCode[5], opCode[4]);    //1's
    // Select between JAL and Branch
    and (JBselect, opCode[6], opCode[5]);
    not (sbz, opCode[2]);
    and (isbranch, JBselect, sbz);
endmodule

module yC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, isStype, isRtype, isItype, isLw, isjump, isbranch);
    output RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg;
    input isStype, isRtype, isItype, isLw, isjump, isbranch;
    // You need two or gates and 3 assignments;
    nor (RegWrite, isStype, isbranch); //isLw, isRtype, isItype);
    nor (ALUSrc, isRtype, isbranch);//isStype, isItype);
    assign Mem2Reg=isLw;        //lw
    assign MemRead=isLw;        //lw
    assign MemWrite=isStype;        //sw
endmodule


module yC4(op, ALUop, funct3);
    output [2:0] op;
    input [2:0] funct3;
    input [1:0] ALUop;
    wire xor1, xor2, and1, notALU, notF3;

    xor (xor1, funct3[2], funct3[1]);
    and (and1, xor1, ALUop[1]);
    or (op[2], ALUop[0], and1);

    xor (xor2, funct3[1], funct3[0]);
    and (op[0], ALUop[1], xor2);

    not (notALU, ALUop[1]);
    not (notF3, funct3[1]);
    or (op[1], notF3, notALU);

    // instantiate and connect

endmodule

module yC3(ALUop, isRtype, isbranch);
    output [1:0] ALUop;
    input isRtype, isbranch;
    // build the circuit
    // Hint: you can do it in only 2 lines
    assign ALUop[0]=isbranch;       //01
    assign ALUop[1]=isRtype;        //10
endmodule


//ALUsrc =0 rs2   =1 imm
module labM;
    reg clk;
    wire [2:0] op;
    wire [6:0] opCode;
    reg INT;
    wire [2:0] funct3;
    wire  ALUSrc, MemRead, MemWrite, Mem2Reg, RegWrite, isjump, isbranch;
    reg [31:0] entryPoint;
    wire [31:0] PCin;
    wire [31:0] PC;
    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z;
    wire [31:0] jTarget, branch, memOut, wb;
    wire zero;
    wire [1:0] ALUop;
    wire  isStype, isRtype, isItype, isLw;

    yIF myIF(ins, PC, PCp4, PCin, clk);
    yID myID(rd1, rd2, imm, jTarget, branch, ins, wd, RegWrite, clk);
    yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
    yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
    yWB myWB(wb, z, memOut, Mem2Reg);
    assign wd = wb;
    yPC myPC(PCin, PC, PCp4, INT, entryPoint, branch, jTarget, zero, isbranch, isjump);
    assign opCode=ins[6:0];
    yC1 myC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
    yC2 myC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, isStype, isRtype, isItype, isLw, isjump, isbranch);
    yC3 myC3(ALUop, isRtype, isbranch);
    assign funct3=ins[14:12];
    yC4 myC4(op, ALUop, funct3);

    initial
    begin
    entryPoint = 32'h28;
    INT=1;
    #1;
    repeat (43)   
    begin

        clk = 1; #1; INT = 0;
        clk = 0; #1;
        
        #5 $display("%h: rd1=%2d rd2=%2d z=%3d zero=%b wb=%2d", ins, rd1, rd2, z, zero, wb);
    end
    $finish;
    end
endmodule