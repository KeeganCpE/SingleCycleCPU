module MainController(
    input  [6:0] opcode,
    output reg branch,
    output reg memRead,
    output reg memToReg,
    output reg memWrite,
    output reg aluScr,
    output reg regWrite,
    output reg [1:0] aluOp
);

always @(*) begin
    // Default values
    branch   = 0;
    memRead  = 0;
    memToReg = 0;
    memWrite = 0;
    aluScr   = 0;
    regWrite = 0;
    aluOp    = 2'b00;

    case (opcode)
        // ADD
        7'b0110011: begin
            regWrite = 1;
            aluOp    = 2'b10;
        end

		  // ADDI
		  7'b0010011: begin
            regWrite = 1;
				aluScr = 1;
        end
		  
        // SW
        7'b0100011: begin
            memWrite = 1;
            aluScr   = 1;
        end

        // BEQ
        7'b1100011: begin
            branch = 1;
            aluOp  = 2'b01;
        end
    endcase
end

endmodule 