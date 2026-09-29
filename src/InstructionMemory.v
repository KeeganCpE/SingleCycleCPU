// InstructionMemory.v
module InstructionMemory(
    input  [31:0] pc,
    output [31:0] instruction
);
    reg [31:0] mem [0:255];

    initial begin
        $readmemh("program.hex", mem);
    end

    assign instruction = mem[pc];
endmodule