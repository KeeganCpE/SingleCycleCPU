module ProgramCounter(
    input clk,
    input reset,
    input [31:0] newPC,
    output reg [31:0] PC
);

	// Change the PC to what it should be, either a jump or pc = pc + 1 (done by pc adder)
	always @(posedge clk or posedge reset) begin
		if (reset)
			PC <= 32'b0;
		else
			PC <= newPC;
	end

endmodule 