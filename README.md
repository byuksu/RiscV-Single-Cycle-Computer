# RISC-V Single Cycle Processor

## Project Description

This project involves the design and simulation of a single cycle processor based on the RISC-V architecture. TThis project investigated a new, open-source instruction set architecture that is gaining traction in the industry and does not require a license. The goal was to build the datapath and control unit of a 32-bit single-cycle RISC-V processor. In this project, the instruction set was extended by adding an additional instruction, enabling the designed processor to execute all commands within the enhanced instruction set. The project is developed in Verilog and has been verified through various test scenarios.

## Features

- Implementation of the basic RISC-V instruction set, including add, sub, lw, sw, beq, etc.
- Each instruction is processed in a single clock cycle.
- The entire processor design is implemented in Verilog.
- A comprehensive testbench has been created to validate the project's correctness.
- Simulates RISC-V instructions and updates register values accordingly.
  
# RISC-V Testbench Using Cocotb

This project involves a testbench for a RISC-V processor, developed using Cocotb (Coroutine-based Co-simulation Testbench). The testbench simulates the execution of RISC-V instructions and evaluates the performance of the Design Under Test (DUT) against expected outcomes. Verification of the computer's operation is achieved through the implementation of a testbench with the following features:

- The testbench reads instructions from a hex file, similar to the HDL computer.
- It executes all instructions autonomously, comparing the resulting values in the register file and the program counter (PC) with those from the HDL design.
- The testbench handles arbitrary RISC-V code composed of the specified RV32I instructions.
- The testbench operates automatically, providing clear indications of any design failures without the need for manual intervention.

# RISC-V Instruction Set Overview

The RISC-V architecture comprises a base Instruction Set Architecture (ISA) along with various extensions. In this project, the implementation focuses on the Unprivileged RV32I Base Integer Instruction Set. Additionally, one new instruction will be introduced as an extension. Instructions such as FENCE, ECALL, EBREAK, and HINT are excluded from implementation due to their irrelevance to this project.

The instructions to be implemented are detailed in Table 1. For further information on these instructions, please refer to the RISC-V specification.

### List of Implemented Instructions:
### Table 1: Instruction List
![image](https://github.com/user-attachments/assets/78bdfa69-2190-4c10-b900-cde055abb54f)


#### Extra Instruction
The additional instruction, XORID, computes the XOR of `rs1` with an embedded constant and stores the result in `rd`. The format for this instruction is as follows:
XORID rd, rs1 => rd ← rs1 ⊕ (studentId1 ⊕ studentId2)
The encoding details for this instruction are as follows:
- **Opcode [6:0]:** 0001011
- **Type:** I type instruction (immediate value will not be utilized)
- **funct3 [2:0]:** 100

## Instruction Set for Testing

The `instructions.hex` file contains a set of instructions used for testing the RISC-V processor implementation. Each instruction is followed by the expected changes in the registers after execution. The following is a list of the instructions along with their corresponding expected register values:

| Address | Instruction              | Operation                        | Expected Register Change                   |
|---------|--------------------------|----------------------------------|-------------------------------------------|
| 0x00    | `addi x31, x0, 0x430`   | `x31 <= 0x00000430`             | `x31 = 1072`                              |
| 0x04    | `ori x30, x0, -0x421`   | `x30 <= 0xFFFFFBDF`             | `x30 = 4294966239`                        |
| 0x08    | `add x29, x30, x31`     | `x29 <= 0x0000000F`             | `x29 = 15`                                |
| 0x0C    | `sub x28, x31, x30`     | `x28 <= 0x00000851`             | `x28 = 2129`                              |
| 0x10    | `and x27, x31, x30`     | `x27 <= 0x00000010`             | `x27 = 16`                                |
| 0x14    | `xor x26, x31, x30`     | `x26 <= 0xFFFFFFEF`             | `x26 = 4294967279`                        |
| 0x18    | `srai x1, x30, 24`      | `x1 <= 0xFFFFFFFF`              | `x1 = 4294967295`                         |
| 0x1C    | `slli x2, x30, 8`       | `x2 <= 0xFFFBDF00`              | `x2 = 4294696704`                         |
| 0x20    | `srl x3, x30, x28`      | `x3 <= 0x00007FFF`              | `x3 = 32767`                              |
| 0x24    | `slt x4, x29, x31`      | `x4 <= 0x00000001`              | `x4 = 1`                                  |
| 0x28    | `sltu x5, x31, x29`     | `x5 <= 0x00000000`              | `x5 = 0`                                  |
| 0x2C    | `slti x6, x30, 0`       | `x6 <= 0x00000001`              | `x6 = 1`                                  |
| 0x30    | `lui x7, 0xABC`         | `x7 <= 0x00ABC000`              | `x7 = 11255808`                           |
| 0x34    | `auipc x8, 0xCDE`       | `x8 <= 0x00CDE034`              | `x8 = 13492276`                           |
| 0x38    | `xorid x9, x27, 0`      | `x9 <= 0x000001A3`              | `x9 = 419`                                |
| 0x3C    | `sw x30, 4(x27)`        | `DataMemory[23:20] <= 0xFFFFFBDF` | DataMemory updated                        |
| 0x40    | `lw x10, 4(x27)`        | `x10 <= 0xFFFFFBDF`             | `x10 = 4294966239`                        |
| 0x44    | `sh x31, 8(x27)`        | `DataMemory[25:24] <= 0x0430`   | DataMemory updated                        |
| 0x48    | `lb x11, 4(x27)`        | `x11 <= 0xFFFFFFDF`             | `x11 = 4294967263`                        |
| 0x4C    | `lhu x12, 7(x27)`       | `x12 <= 0x000030FF`             | `x12 = 12543`                             |
| 0x50    | `bne x30, x31, 12`      | `PC <= 0x0000005C`              | PC updated                                 |
| 0x5C    | `bge x26, x29, 12`      | PC unchanged                     |                                           |
| 0x60    | `bltu x30, x29, 8`      | PC unchanged                     |                                           |
| 0x64    | `addi x0, x0, 0`        | No change                       |                                           |
| 0x68    | `jal x13, 4`            | `x13 <= 0x0000006C` <br> `PC <= 0x0000006C` |                                           |
| 0x6C    | `jalr x14, 8(x13)`      | `x14 <= 0x00000070` <br> `PC <= 0x00000074` |                                           |
| 0x74    | `jal x0, -4`            | `PC <= 0x00000070`              |                                           |

This table outlines each instruction's address, its operation, and the expected changes in the relevant registers, providing a comprehensive overview of the testing process for the RISC-V processor implementation.

