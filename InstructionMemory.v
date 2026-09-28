module InstructionMemory(
    input  [31:0] pc,
    output reg [31:0] instruction
);

    always @(*) begin
        case (pc)
            // 0: addi x1, x0, 5
            0: instruction = 32'h00500093;

            // 1: addi x2, x0, 7
            1: instruction = 32'h00700113;

            // 2: add x3, x1, x2
            2: instruction = 32'h002081B3;

            // 3: sw x3, 0(x0)
            3: instruction = 32'h00302023;

            // 4: beq x3, x3, -4   (branch to PC=0)
            4: instruction = 32'hFE319EE3;

            default: instruction = 32'h00000000;
        endcase
    end

endmodule 