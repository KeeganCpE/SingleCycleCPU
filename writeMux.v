module writeMux(
	input memToReg,
	input [31:0] aluRes, readData,
	output [31:0] result
);

	assign result = (memToReg == 1'b1) ? readData : aluRes;

endmodule 