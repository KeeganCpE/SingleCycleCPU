`timescale 1ns/1ps

module DE10_Nano_Top_tb;

    reg FPGA_CLK1_50 = 0;
    reg [1:0] KEY = 2'b11;  // Unpressed (active-low 1)
    reg [3:0] SW = 4'b0000;
    wire [7:0] LEDR;

    // Instantiate Top-Level
    DE10_Nano_Top #(
        // Override DIV_FACTOR for fast simulation
        .clk_div.DIV_FACTOR(5)
    ) dut (
        .FPGA_CLK1_50(FPGA_CLK1_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR)
    );

    // 50 MHz Clock Generator (20ns period)
    always #10 FPGA_CLK1_50 = ~FPGA_CLK1_50;

    initial begin
        // Apply reset via KEY[0]
        #40 KEY[0] = 0;  // Press reset button
        #40 KEY[0] = 1;  // Release reset button

        // Run simulation to observe LED updates
        #2000;
        $finish;
    end

endmodule 