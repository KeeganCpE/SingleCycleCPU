module DE10_Nano_Top (
    input        FPGA_CLK1_50,  // Onboard 50 MHz oscillator
    input  [1:0] KEY,           // Pushbuttons (Active-Low)
    input  [3:0] SW,            // Slide Switches
    output [7:0] LEDR           // Onboard Green LEDs
);

    wire sys_reset = ~KEY[0];   // Invert active-low button to active-high reset
    wire cpu_clk;

    // Slow clock module (e.g., 1 Hz or 4 Hz for visible LED stepping)
    ClkDivider #(.DIV_FACTOR(25_000_000)) clk_div (
        .clk_in(FPGA_CLK1_50),
        .rst(sys_reset),
        .clk_out(cpu_clk)
    );

    // CPU core instantiation
    wire [31:0] pc_debug;
    wire [31:0] alu_debug;

    CPU cpu_inst (
        .clk(cpu_clk),
        .reset(sys_reset)
    );

    // Map internal CPU state to physical LEDs for hardware debugging
    // SW[0] toggles whether LEDs display lower 8 bits of PC or ALU Result
    assign LEDR = (SW[0]) ? alu_debug[7:0] : pc_debug[7:0];

endmodule