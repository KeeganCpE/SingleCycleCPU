module ClkDivider #(parameter DIV_FACTOR = 25_000_000) (
    input clk_in,
    input rst,
    output reg clk_out
);
    reg [31:0] count;

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            count <= 0;
            clk_out <= 0;
        end else if (count == DIV_FACTOR - 1) begin
            count <= 0;
            clk_out <= ~clk_out;
        end else begin
            count <= count + 1;
        end
    end
endmodule