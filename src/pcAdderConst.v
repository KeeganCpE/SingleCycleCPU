module pcAdderConst(
	input [31:0] pc,
	output [31:0] newPC
);

	assign newPC = pc + 1;

endmodule 