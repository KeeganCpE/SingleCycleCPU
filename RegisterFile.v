module RegisterFile (
    input clk,
    input RegWrite,
    input [4:0] Reg1, Reg2, WriteReg,
    input [31:0] WriteData,
    output [31:0] ReadData1, ReadData2
);

    // 32 registers, each 32 bits
    reg [31:0] regs [0:31];

    // Hardwire x0 to zero
    always @(posedge clk) begin
        if (RegWrite && WriteReg != 0)
            regs[WriteReg] <= WriteData;

        regs[0] <= 32'b0;  // enforce x0 = 0
    end

    // Combinational reads
    assign ReadData1 = (Reg1 == 0) ? 32'b0 : regs[Reg1];
    assign ReadData2 = (Reg2 == 0) ? 32'b0 : regs[Reg2];

endmodule 