# 32-Bit Single-Cycle RISC-V Processor (Verilog)

A modular, single-cycle 32-bit processor supporting a subset of the **RISC-V (RV32I)** instruction set architecture, implemented in Verilog HDL.

---

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Supported Instruction Set](#supported-instruction-set)
- [Control Signals Matrix](#control-signals-matrix)
- [Built-in Sample Program](#built-in-sample-program)
- [Directory & Module Structure](#directory--module-structure)
- [Getting Started & Simulation](#getting-started--simulation)
  - [Using Icarus Verilog & GTKWave](#using-icarus-verilog--gtkwave)
  - [Using ModelSim / QuestaSim](#using-modelsim--questasim)

---

## Architecture Overview

This processor implements a classic single-cycle Harvard architecture (separate instruction and data memories). In each clock cycle, the processor fetches an instruction, decodes it, reads register operands, executes the ALU operation, accesses memory (if applicable), and writes the result back to the register file.

```
       +-------------------------------------------------------------+
       |                                                             |
       v                                                             |
[ ProgramCounter ] ---> [ InstructionMemory ] ---> [ MainController ]|
       |                         |                       |           |
       +-------> [ Adders ] <----+                       v           |
                    |        |                 [ Control Lines ]     |
                    v        |                           |           |
               [ pcMux ]     +--> [ ImmGen ]             |           |
                   |                     |               v           |
                   +---> [ RegFile ] <---+-------> [ ALU Mux ]       |
                             |                        |              |
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
* **Instruction Memory (ROM):** Pre-loaded memory containing machine code instructions.
* **Register File:** 32 general-purpose 32-bit registers ($x0$ is hardwired to `0`). Supports synchronous writes and combinational reads.
* **Immediate Generator (ImmGen):** Extracts sign-extended immediate values for I-type, S-type, and B-type instructions.
* **Arithmetic Logic Unit (ALU) & Controller:** Executes arithmetic/logical operations and computes condition flags (e.g., `zero`).
* **Data Memory (RAM):** 256-word synchronous-write, combinational-read memory.
* **Control Units:** `MainController` handles control signals based on standard opcodes, while `ALUController` calculates the 4-bit ALU operation signal based on `aluOp`, `funct3`, and `funct7`.

---

## Supported Instruction Set

The processor currently implements a core baseline subset of the RV32I instruction set:

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

The `InstructionMemory.v` module includes a pre-loaded loop test program:

```assembly
# PC = 0: Load 5 into register x1
0: addi x1, x0, 5     # Hex: 0x00500093

# PC = 1: Load 7 into register x2
1: addi x2, x0, 7     # Hex: 0x00700113

# PC = 2: Add x1 and x2, store result (12) in x3
2: add  x3, x1, x2    # Hex: 0x002081B3

# PC = 3: Store value in x3 (12) to Data Memory at address 0
3: sw   x3, 0(x0)     # Hex: 0x00302023

# PC = 4: Branch back to instruction at PC = 0
4: beq  x3, x3, -4    # Hex: 0xFE319EE3
```

---

## Directory & Module Structure

| File Name | Description |
| :--- | :--- |
| **`CPU.v`** | Top-level module interconnecting all datapath components and controllers. |
| **`CPU_tb.v`** | Top-level testbench for running simulation and clock generation. |
| **`ProgramCounter.v`** | Register holding the current instruction memory address. |
| **`InstructionMemory.v`** | Hardcoded ROM storing program instructions. |
| **`RegisterFile.v`** | $32 \times 32$-bit register file ($x0$ fixed at 0). |
| **`MainController.v`** | Decodes instructions to set primary control flags. |
| **`ALUController.v`** | Generates specific 4-bit ALU operational codes based on control signals and instruction subfields (`funct3`, `funct7`). |
| **`ALU.v`** | Performs arithmetic calculations (`ADD`, `SUB`) and evaluates flags (`zero`). |
| **`ImmGen.v`** | Generates 32-bit sign-extended immediates from I, S, and B instruction formats. |
| **`DataMemory.v`** | Data memory array supporting load/store operations. |
| **`pcAdderConst.v`** | Increments PC sequentially (`PC + 1`). |
| **`pcAdderImm.v`** | Calculates branch target address (`PC + Immediate`). |
| **`pcMux.v`** | Selects between sequential PC or target jump PC based on branch decision. |
| **`aluMux.v`** | Selects second operand source for ALU (Register or Immediate). |
| **`writeMux.v`** | Selects write-back data source for registers (ALU result or Data Memory). |

---

## Getting Started & Simulation

### Using Icarus Verilog & GTKWave

1. **Compile all Verilog modules:**
   ```bash
   iverilog -o cpu_sim CPU_tb.v CPU.v ProgramCounter.v InstructionMemory.v RegisterFile.v MainController.v ALUController.v ALU.v ImmGen.v DataMemory.v pcAdderConst.v pcAdderImm.v pcMux.v aluMux.v writeMux.v
   ```

2. **Execute the compiled simulation:**
   ```bash
   vvp cpu_sim
   ```

3. **(Optional)** Add waveform dumping (`$dumpfile` / `$dumpvars`) in `CPU_tb.v` to inspect waveforms using **GTKWave**:
   ```bash
   gtkwave dump.vcd
   ```

### Using ModelSim / QuestaSim

1. Create a project and add all `.v` files to the workspace.
2. Compile all files.
3. Start simulation with `CPU_tb` as the top-level module.
4. Add desired signals (e.g., `dut/PC`, `dut/regs/regs`, `dut/dmem/mem`) to the Wave window and run for `500ns`.
