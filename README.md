# 32-Bit Single-Cycle RISC-V Processor (Verilog)

A modular, single-cycle 32-bit processor supporting a subset of the **RISC-V (RV32I)** instruction set architecture, implemented in Verilog HDL and fully deployed on the **Terasic DE10-Nano FPGA** (Intel Cyclone V).

---

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [FPGA Implementation & Hardware Interface](#fpga-implementation--hardware-interface)
- [Supported Instruction Set](#supported-instruction-set)
- [Control Signals Matrix](#control-signals-matrix)
- [Built-in Sample Program](#built-in-sample-program)
- [Directory & Module Structure](#directory--module-structure)
- [Simulation & Verification](#simulation--verification)
- [FPGA Synthesis & Flashing (Quartus Prime)](#fpga-synthesis--flashing-quartus-prime)

---

## Architecture Overview

This processor implements a classic single-cycle Harvard architecture (separate instruction and data memories). In each clock cycle, the processor fetches an instruction, decodes it, reads register operands, executes the ALU operation, accesses memory (if applicable), and writes the result back to the register file.

```text
       +-------------------------------------------------------------+
       |                                                             |
       v                                                             |
[ ProgramCounter ] ---> [ InstructionMemory ] ---> [ MainController ]|
       |                          |                        |         |
       +-------> [ Adders ] <-----+                        v         |
                    |        |                  [ Control Lines ]    |
                    v        |                            |          |
               [ pcMux ]     +--> [ ImmGen ]              |          |
                   |                     |                v          |
                   +---> [ RegFile ] <---+-------> [ ALU Mux ]       |
                             |                         |             |
                             +--------------------+   v              |
                                                  |->[ ALU ]         |
                                                      |              |
                                                      v              |
                                               [ DataMemory ]        |
                                                      |              |
                                                      v              |
                                                 [ WriteMux ]--------+
```

### Key Hardware Components
* **Program Counter (PC):** Holds the address of the current instruction.
* **Instruction Memory (ROM):** Memory initialized via `$readmemh` with hex machine code (`program.hex`).
* **Register File:** 32 general-purpose 32-bit registers ($x0$ is hardwired to `0`). Supports synchronous writes and combinational reads.
* **Immediate Generator (ImmGen):** Extracts sign-extended immediate values for I-type, S-type, and B-type instructions.
* **Arithmetic Logic Unit (ALU) & Controller:** Executes arithmetic/logical operations and computes condition flags (e.g., `zero`).
* **Data Memory (RAM):** 256-word synchronous-write, combinational-read memory.
* **Control Units:** `MainController` handles control signals based on standard opcodes, while `ALUController` calculates the 4-bit ALU operation signal based on `aluOp`, `funct3`, and `funct7`.
* **Hardware Debug Ports:** `CPU.v` exposes `pc_debug` and `alu_debug` outputs to route internal execution state directly to physical FPGA peripherals.

---

## FPGA Implementation & Hardware Interface

The CPU core is mapped onto the **Terasic DE10-Nano** development board (`5CSEBA6U23I7` Cyclone V SoC FPGA) using `DE10_Nano_Top.v` as the hardware wrapper and `ClkDivider.v` to step down the 50 MHz oscillator to a human-observable clock rate.

### Peripheral Mapping

| Hardware Peripheral | FPGA Pin | Signal Name | Function / Description |
| :--- | :--- | :--- | :--- |
| **50 MHz Oscillator** | `PIN_V11` | `FPGA_CLK1_50` | System reference clock input. |
| **Pushbutton 0** | `PIN_AH17` | `KEY[0]` | **System Reset** (Active-Low): Pressing resets PC to `0x00`. |
| **Slide Switch 0** | `PIN_Y24` | `SW[0]` | **LED Output Multiplexer**: Selects display mode for `LEDR`. |
| **Green LEDs 0–7** | `PIN_W15` ... `PIN_Y15` | `LEDR[7:0]` | Active output display driven by `SW[0]`. |

### LED Display Selection (`SW[0]`)
* **`SW[0] = 0` (DOWN):** Displays the lower 8 bits of the **Program Counter** (`pc_debug[7:0]`). Allows visual verification of instruction stepping and branch looping.
* **`SW[0] = 1` (UP):** Displays the lower 8 bits of the **ALU Output** (`alu_debug[7:0]`). Shows live arithmetic results calculated during runtime.

---

## Supported Instruction Set

The processor implements a baseline core subset of the RV32I instruction set:

| Instruction | Type | Format / Encoding Example | Description |
| :--- | :---: | :--- | :--- |
| **`ADD`** | R-Type | `add x3, x1, x2` | Adds contents of `x1` and `x2`, stores in `x3`. |
| **`ADDI`** | I-Type | `addi x1, x0, 5` | Adds sign-extended immediate to `x0`, stores in `x1`. |
| **`SW`** | S-Type | `sw x3, 0(x0)` | Stores contents of `x3` into Data Memory at address `x0 + 0`. |
| **`BEQ`** | B-Type | `beq x3, x3, -4` | Branches to target address if `x3 == x3`. |

---

## Control Signals Matrix

The `MainController` decodes the 7-bit opcode (`instruction[6:0]`) to output hardware control signals:

| Instruction | Opcode (`[6:0]`) | `regWrite` | `aluScr` | `memWrite` | `memRead` | `memToReg` | `branch` | `aluOp` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`ADD`** | `7'b0110011` | `1` | `0` | `0` | `0` | `0` | `0` | `2'b10` |
| **`ADDI`** | `7'b0010011` | `1` | `1` | `0` | `0` | `0` | `0` | `2'b00` |
| **`SW`** | `7'b0100011` | `0` | `1` | `1` | `0` | `0` | `0` | `2'b00` |
| **`BEQ`** | `7'b1100011` | `0` | `0` | `0` | `0` | `0` | `1` | `2'b01` |

---

## Built-in Sample Program

The processor synthesizes with a pre-loaded test program in `fpga/program.hex`, loaded via `$readmemh` inside `InstructionMemory.v`:

```assembly
# Address 0: Load 5 into register x1
0: addi x1, x0, 5     # Machine Code: 0x00500093

# Address 1: Load 7 into register x2
1: addi x2, x0, 7     # Machine Code: 0x00700113

# Address 2: Add x1 and x2, store result (12) in x3
2: add  x3, x1, x2    # Machine Code: 0x002081b3

# Address 3: Store value in x3 (12 / 0x0C) to Data Memory address 0
3: sw   x3, 0(x0)     # Machine Code: 0x00302023

# Address 4: Branch back to instruction at Address 0
4: beq  x3, x3, -4    # Machine Code: 0xfe319ee3
```

---

## Directory & Module Structure

```text
.
├── src/                        # Platform-Agnostic CPU RTL Core
│   ├── CPU.v                   # Top-level CPU core (exposes pc_debug & alu_debug)
│   ├── ALU.v                   # 32-bit Arithmetic Logic Unit
│   ├── ALUController.v         # 4-bit ALU operation decoder
│   ├── DataMemory.v            # Synchronous RAM module
│   ├── ImmGen.v                # Immediate sign-extension unit
│   ├── InstructionMemory.v     # ROM pre-loaded via $readmemh("program.hex")
│   ├── MainController.v        # Main instruction decoder
│   ├── ProgramCounter.v        # PC register
│   ├── RegisterFile.v          # 32 x 32-bit register file (x0 hardwired to 0)
│   ├── aluMux.v                # ALU operand B selector
│   ├── pcAdderConst.v          # Sequential PC increment adder
│   ├── pcAdderImm.v            # Branch target calculation adder
│   ├── pcMux.v                 # Next-PC multiplexer
│   └── writeMux.v              # Register write-back multiplexer
├── fpga/                       # DE10-Nano Synthesis & Quartus Project
│   ├── DE10_Nano_Top.v         # Hardware top wrapper (clock div, pin muxing)
│   ├── ClkDivider.v            # Parameterized clock divider module
│   ├── DE10_Nano.qsf           # Pin assignments & device configuration
│   ├── DE10_Nano_Top.sdc       # Timing constraints file (50 MHz & derived clock)
│   ├── program.hex             # Initial memory image (hex machine code)
│   └── output_files/
│       └── DE10_Nano_Top.sof   # Compiled FPGA bitstream file
├── testbench/                  # Simulation Files (Excluded from Synthesis)
│   ├── CPU_tb.v                # Core CPU simulation testbench
│   └── DE10_Nano_Top_tb.v      # Hardware wrapper testbench
└── README.md
```

---

## Simulation & Verification

Testbenches are located in `testbench/` and must remain separate from the Quartus synthesis file list.

### Using Icarus Verilog & GTKWave

1. **Compile the CPU core and testbench:**
   ```bash
   iverilog -o cpu_sim testbench/CPU_tb.v src/*.v
   ```

2. **Execute the simulation:**
   ```bash
   vvp cpu_sim
   ```

3. **Inspect Waveforms in GTKWave:**
   ```bash
   gtkwave dump.vcd
   ```

### Using ModelSim / QuestaSim

1. Create a workspace project and add all files in `src/` and `testbench/`.
2. Set `CPU_tb` or `DE10_Nano_Top_tb` as the top-level module.
3. Run simulation for `2000ns` and observe `PC`, `aluResult`, and `LEDR` outputs.

---

## FPGA Synthesis & Flashing (Quartus Prime)

### 1. Compilation
1. Open Intel Quartus Prime Lite (Version 20.1 or newer).
2. Open the project file: `fpga/DE10_Nano.qsf`.
3. Verify that all Verilog files in `src/`, `fpga/DE10_Nano_Top.v`, and `fpga/ClkDivider.v` are included (ensure testbench files are excluded from synthesis).
4. Run **Start Compilation** (`Ctrl + L`). Ensure compilation completes with **0 Errors**.

### 2. Hardware Flashing
1. Connect power to the DE10-Nano board.
2. Connect the USB cable from your PC to the **USB-Blaster II** Mini-USB port on the board.
3. Open **Quartus Programmer** (`Tools > Programmer`).
4. Click **Hardware Setup...** and select **`DE-SoC [USB-1]`** (or `USB-Blaster II`) under **Currently selected hardware**.
5. Click **Auto Detect** and choose **`5CSEBA6`** if prompted.
6. Right-click the **`5CSEBA6`** entry in the device chain $\rightarrow$ **Change File** $\rightarrow$ select `fpga/output_files/DE10_Nano_Top.sof`.
7. Check the **Program/Configure** box for `5CSEBA6` and click **Start**.
8. Once the progress bar reaches **100% Successful**, the processor will execute live on hardware.

### Example demonstrating the flashed program.hex with PC counting, resetting PC, and showing ALU value:
https://github.com/user-attachments/assets/1018105e-b3ee-4b1b-b48a-a95569d67a10
