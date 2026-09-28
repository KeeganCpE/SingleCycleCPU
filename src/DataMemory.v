module DataMemory(
    input clk,
    input memWrite,
    input memRead,
    input [31:0] address,
    input [31:0] writeData,
    output reg [31:0] readData
);

    // 256-word data memory (adjust size as needed)
    reg [31:0] mem [0:255];

    // Synchronous write
    always @(posedge clk) begin
        if (memWrite)
            mem[address] <= writeData;
    end

    // Combinational read
    always @(*) begin
        if (memRead)
            readData = mem[address];
        else
            readData = 32'b0;
    end

endmodule 