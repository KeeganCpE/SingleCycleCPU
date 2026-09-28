module pcAdderImm(
	input [31:0] immediate,
	input [31:0] pc,
	output [31:0] result
);

	assign result = pc + immediate;

endmodule 