module aluMux(
	input aluOp,
	input [31:0] data2, imm,
	output [31:0] result
);

	assign result = (aluOp == 1'b1) ? imm : data2;

endmodule 