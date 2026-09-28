module CPU(
    input clk,
    input reset
);

    //
    // === PROGRAM COUNTER ===
    //
    wire [31:0] PC;
    wire [31:0] constPC;
    wire [31:0] jumpPC;
    wire [31:0] nextPC;

    ProgramCounter pc_reg(
        .clk(clk),
        .reset(reset),
        .newPC(nextPC),
        .PC(PC)
    );

    pcAdderConst pc_plus_1(
        .pc(PC),
        .newPC(constPC)
    );

    //
    // === INSTRUCTION MEMORY ===
    //
    wire [31:0] instruction;

    InstructionMemory imem(
        .pc(PC),
        .instruction(instruction)
    );

    //
    // === MAIN CONTROLLER ===
    //
    wire branch, memRead, memToReg, memWrite, aluScr, regWrite;
    wire [1:0] aluOp;

    MainController control(
        .opcode(instruction[6:0]),
        .branch(branch),
        .memRead(memRead),
        .memToReg(memToReg),
        .memWrite(memWrite),
        .aluScr(aluScr),
        .regWrite(regWrite),
        .aluOp(aluOp)
    );

    //
    // === REGISTER FILE ===
    //
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] WriteData;

    RegisterFile regs(
        .clk(clk),
        .RegWrite(regWrite),
        .Reg1(instruction[19:15]),
        .Reg2(instruction[24:20]),
        .WriteReg(instruction[11:7]),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    //
    // === IMMEDIATE GENERATOR ===
    //
    wire [31:0] imm;

    ImmGen immgen(
        .instruction(instruction),
        .imm(imm)
    );

    //
    // === ALU INPUT MUX (ALUSrc) ===
    //
    wire [31:0] aluInput2;

    aluMux alusrc_mux(
        .aluOp(aluScr),
        .data2(ReadData2),
        .imm(imm),
        .result(aluInput2)
    );

    //
    // === ALU CONTROLLER ===
    //
    wire [3:0] aluControl;

    ALUController alu_ctrl(
        .aluOp(aluOp),
        .instruction(instruction),
        .aluControl(aluControl)
    );

    //
    // === ALU ===
    //
    wire [31:0] aluResult;
    wire zero;

    ALU alu(
        .aluControl(aluControl),
        .data1(ReadData1),
        .data2(aluInput2),
        .aluResult(aluResult),
        .zero(zero)
    );

    //
    // === DATA MEMORY ===
    //
    wire [31:0] readData;

    DataMemory dmem(
        .clk(clk),
        .memWrite(memWrite),
        .memRead(memRead),
        .address(aluResult),
        .writeData(ReadData2),
        .readData(readData)
    );

    //
    // === WRITEBACK MUX (MemToReg) ===
    //
    writeMux wb_mux(
        .memToReg(memToReg),
        .aluRes(aluResult),
        .readData(readData),
        .result(WriteData)
    );

    //
    // === PC + Immediate (for branches) ===
    //
    pcAdderImm pc_plus_imm(
        .immediate(imm),
        .pc(PC),
        .result(jumpPC)
    );

    //
    // === PC SELECT MUX ===
    //
    pcMux pcmux(
        .branch(branch),
        .zero(zero),
        .constPC(constPC),
        .jumpPC(jumpPC),
        .result(nextPC)
    );

endmodule
