# Complete Existing Project Audit

## 1. Project Overview

- **Repository**: RISC-V-CPU-Using-Verilog-HDL (existing workspace)
- **Primary Domain**: Digital logic design portfolio, basic combinational and sequential Verilog blocks.
- **Audit Date**: 2026-11-11
- **Status Summary**: The repository currently contains introductory combinational arithmetic (bitwise half-adder, 4-bit ripple-carry adder), sequential logic (registered adder), a basic 4-bit ALU, and a single Moore FSM (washing machine controller). Despite the repository folder name referencing "RISC-V-CPU", **no RISC-V processor, datapath, pipeline stage, register file, memory module, or hazard unit is implemented in the existing codebase**.

---

## 2. Inventory and Component Classification

Components are classified using the 6 standard audit tiers:
1. *Implemented and verified*
2. *Implemented but not verified*
3. *Partially implemented*
4. *Present but nonfunctional*
5. *Missing*
6. *Planned but not implemented*

### 2.1 Existing RTL Modules

| Component | Source File | Lines of Code | Classification | Technical Assessment & Findings |
|---|---|---|---|---|
| **4-bit Bitwise Half-Adder** | [`4bit_half_adder/half_adder4.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/4bit_half_adder/half_adder4.v) | 13 | Implemented but not verified | Computes bitwise `A ^ B` and `A & B`. Does not propagate carry across bit positions. Legacy exercise file. |
| **Legacy 4-bit ALU** | [`project/alu4bit/alu4.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/project/alu4bit/alu4.v) | 65 | Implemented but not verified | Supports ADD, SUB, AND, OR, XOR. Uses combinational `always @(*)` with `temp` register for carry. Zero flag logic present. |
| **4-bit Ripple-Carry Adder** | [`rtl/ripple_adder_4bit.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/rtl/ripple_adder_4bit.v) | 32 | Implemented but not verified | Clean structural implementation using `generate` loop over 4 `full_adder_1bit` instances. Synthesizable. |
| **4-bit Registered Adder** | [`rtl/registered_adder_4bit.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/rtl/registered_adder_4bit.v) | 27 | Implemented but not verified | Instantiates `ripple_adder_4bit`. Synchronous active-high reset registers output on clock edge. Synthesizable. |
| **4-bit ALU (Clean RTL)** | [`rtl/alu_4bit.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/rtl/alu_4bit.v) | 37 | Implemented but not verified | Structured 4-bit ALU: ADD (`000`), SUB (`001`), AND (`010`), OR (`011`), XOR (`100`). Continuous zero flag assignment. |
| **Washing Machine Controller** | [`rtl/wash_controller.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/rtl/wash_controller.v) | 63 | Implemented but not verified | 7-state Moore FSM: IDLE, FILL, WASH, DRAIN, RINSE, SPIN, DONE. Asynchronous reset, synchronous transitions. Safe default output values. |

### 2.2 Existing Testbenches

| Testbench | Path | Lines of Code | Assessment |
|---|---|---|---|
| `half_adder4_tb.v` | [`4bit_half_adder/half_adder4_tb.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/4bit_half_adder/half_adder4_tb.v) | 37 | Basic stimulus with `$display`. Only tests 4 manual vectors. |
| `alu4_tb.v` | [`project/alu4bit/alu4_tb.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/project/alu4bit/alu4_tb.v) | 59 | Basic stimulus testing 6 operations. Not self-checking. |
| `tb_ripple_adder_4bit.v` | [`tb/tb_ripple_adder_4bit.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/tb/tb_ripple_adder_4bit.v) | 36 | Self-checking. Loops over all 512 combinations of `A`, `B`, and `cin`. Tracks errors. |
| `tb_registered_adder_4bit.v` | [`tb/tb_registered_adder_4bit.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/tb/tb_registered_adder_4bit.v) | 33 | Self-checking. Checks reset assertion and registered sample behavior. |
| `tb_alu_4bit.v` | [`tb/tb_alu_4bit.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/tb/tb_alu_4bit.v) | 51 | Self-checking. Checks add with carry, sub with borrow, bitwise logic, and zero flag. |
| `tb_wash_controller.v` | [`tb/tb_wash_controller.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/tb/tb_wash_controller.v) | 56 | Self-checking. Cycles through all 7 states, checks sensor handshakes and actuator asserts. |

### 2.3 RISC-V and Architecture Components (Existing Repo)

| Architectural Category | Component | Existing Status |
|---|---|---|
| **RISC-V Processors** | Single-cycle / 2-stage / 5-stage / 7-stage CPU | **Missing** (None exists in workspace) |
| **Pipeline Stages** | IF, ID, EX, MEM, WB pipeline registers | **Missing** |
| **Hazard Handling** | Hazard Detection Unit, Load-Use Stall, Branch Flush | **Missing** |
| **Data Forwarding** | Forwarding Unit (EX-to-EX, MEM-to-EX, WB-to-ID) | **Missing** |
| **Instruction Decoding** | RV32I Immediate Generator, Instruction Decoder | **Missing** |
| **Register File** | 32-bit x 32-entry dual-read single-write with x0=0 | **Missing** |
| **RISC-V ALU & Shifter** | 32-bit RV32I ALU & Barrel Shifter | **Missing** |
| **Memory Subsystems** | Synchronous RAM, ROM ($readmemh), Synchronous FIFO | **Missing** |
| **System Architecture** | Round-Robin Arbiter, Watchdog Timer | **Missing** |
| **FSM Controllers** | Elevator, ATM, Vending Machine, Traffic Light, Sequence Detectors | **Missing** (Only wash controller present) |
| **Digital Design Blocks** | Carry Adder/Subtractor, Counter, LFSR, Shift Reg, Edge/Debounce, Encoders | **Missing** |

---

## 3. Existing Project Documentation and Review Findings

- **[`README.md`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/README.md)**: Explicitly and honestly states: *"This is a collection of digital-design exercises, not a CPU or a complete RISC-V implementation. The downloaded processor example uses a custom instruction encoding and should not be described as ISA-compliant RISC-V."*
- **[`docs/source-review.md`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/docs/source-review.md)**: Documents a technical audit of 6 downloaded folders from 2026-11-02, identifying limitations in toy processor implementations that used non-standard 4-bit opcodes and 3-bit register indices.

## 4. Key Takeaways for Upgrade

1. The existing project has high quality, cleanly written, synthesizable Verilog code for the basic modules it contains, with honest documentation.
2. The primary gap is the **complete absence of actual RISC-V processor implementations and broader digital design / memory / FSM modules**.
3. We must upgrade this repository by integrating genuine RV32I-compliant processors, complete verification suites, and all missing digital design building blocks without overwriting the existing clean work.
