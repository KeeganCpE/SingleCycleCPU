module CPU_tb;

    reg clk = 0;
    reg reset = 1;

    // Instantiate CPU
    CPU dut(
        .clk(clk),
        .reset(reset)
    );

    // Clock generator
    always #5 clk = ~clk;  // 10ns period

    initial begin
        // Release reset after a few cycles
        #20 reset = 0;

        // Run long enough to see the loop
        #500 $stop;
    end

endmodule 