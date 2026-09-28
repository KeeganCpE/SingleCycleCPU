module ImmGen(
	input  [31:0] instruction,
	output reg [31:0] imm
);

	wire [6:0] opcode = instruction[6:0];

	always @(*) begin
		case (opcode)

			// I-type (ADDI)
			7'b0010011: begin
				imm = {{20{instruction[31]}}, instruction[31:20]};
			end

			// S-type (SW)
			7'b0100011: begin
				imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
			end

			// B-type (BEQ)
			7'b1100011: begin
				imm = {{19{instruction[31]}},
					instruction[31],
					instruction[7],
					instruction[30:25],
					instruction[11:8],
					1'b0};   // LSB is always 0 (word aligned)
			end

			default: imm = 32'b0;  // For ADD or unknown opcodes
		endcase
	end

endmodule 