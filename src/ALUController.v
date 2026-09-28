module ALUController(
	input  [1:0] aluOp,
	input  [31:0] instruction,
	output reg [3:0] aluControl
);

	wire [2:0] funct3 = instruction[14:12];
	wire [6:0] funct7 = instruction[31:25];

	always @(*) begin
		case (aluOp)

			// 00 → ADD (ADDI, SW)
			2'b00: aluControl = 4'b0010;

			// 01 → SUB (BEQ)
			2'b01: aluControl = 4'b0110;

			// 10 → R-type (ADD or SUB)
			2'b10: begin
				if (funct3 == 3'b000) begin
					if (funct7 == 7'b0100000)
						aluControl = 4'b0110; // SUB
					else
						aluControl = 4'b0010; // ADD
					end else begin
						aluControl = 4'b0000; // unused
					end
			end

			default: aluControl = 4'b0000;
		endcase
	end

endmodule 