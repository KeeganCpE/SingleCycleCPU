module ALU(
	input [3:0] aluControl,
	input [31:0] data1, data2,
	output reg [31:0] aluResult,
	output zero
);

	always @(*) begin
		case (aluControl)
			4'b0010: aluResult = data1 + data2; // ADD
			4'b0110: aluResult = data1 - data2; // SUB (for BEQ)
			default: aluResult = 32'b0;         // unused
		endcase
	end

	assign zero = (aluResult == 32'b0);

endmodule 