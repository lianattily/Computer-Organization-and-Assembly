
module yC3(ALUop, isRtype, isbranch);
    output [1:0] ALUop;
    input isRtype, isbranch;
    // build the circuit
    // Hint: you can do it in only 2 lines
    assign ALUop[0]=isbranch;       //01
    assign ALUop[1]=isRtype;        //10
endmodule

//yC4= ALU control unit
//(2 not, 2 xor, 2 and, 2 or gates)
//AND1 = F3[2] xor F3[1] AND ALUop[1] .. op[0]=F3[1] xor F3[0] AND ALUop[1] ...op[1]= not(ALUop[1]) OR not(F3[1]) ... op[2]= ALUop[0] OR AND1

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

module yChip(ins, rd2, wb, entryPoint, INT, clk);
    output [31:0] ins, rd2, wb;
    input [31:0] entryPoint;
    input INT, clk;
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
endmodule