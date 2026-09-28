module pcMux(
	input branch, zero,
	input [31:0] constPC, jumpPC,
	output [31:0] result
);

	assign result = (branch && zero) ? jumpPC : constPC;

endmodule 