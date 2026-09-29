# Primary 50 MHz clock
create_clock -period 20.000 -name FPGA_CLK1_50 [get_ports FPGA_CLK1_50]

# Generated clock output from ClkDivider
create_generated_clock -name cpu_clk -source [get_ports FPGA_CLK1_50] [get_registers {clk_div|clk_out}]

derive_clock_uncertainty