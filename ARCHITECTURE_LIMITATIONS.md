# RISC-V Architectural Boundaries and Limitations

This document provides a transparent, technically rigorous assessment of the current processor architecture, detailing its supported capabilities, deliberate design constraints, and future upgrade boundaries.

---

## 1. Executive Capability Status

The processor implemented in [`rtl/riscv/riscv_core_5stage.v`](file:///c:/Users/chenn/Downloads/Risk_CPU/RISC-V-CPU-Using-Verilog-HDL-main/rtl/riscv/riscv_core_5stage.v) is a fully functional, synthesizable **RV32I + RV32M** 5-stage in-order pipelined CPU core. It features complete data forwarding, load-use interlocks, speculative branch redirection, and byte/halfword memory addressing.

---

## 2. Architectural Boundaries & Limitations

### 1. Memory Subsystem and Hierarchy
* **Current Implementation**: The processor interfaces directly with a single-cycle synchronous SRAM memory array for instructions and data.
* **Limitations**:
  - **No L1 Caches**: There are no instruction or data caches (I-Cache / D-Cache). All loads and stores operate under the assumption of 1-cycle latency.
  - **No Memory Management Unit (MMU)**: Virtual memory paging (Sv32) is unsupported; memory addresses are direct physical addresses.
  - **No External Bus Controller**: Standard system buses such as AXI4, AHB-Lite, or Wishbone are not yet wrapped around the core memory ports.

---

### 2. Privileged Architecture & Interrupt Handling
* **Current Implementation**: The core executes exclusively in unprivileged user integer mode.
* **Limitations**:
  - **Control and Status Registers (CSRs)**: Control and Status Registers (`mstatus`, `mie`, `mtvec`, `mepc`, `mcause`, `mip`) are not implemented.
  - **System Instructions**: `CSRRW`, `CSRRS`, `CSRRC`, `CSRRWI`, `CSRRSI`, `CSRRCI`, `ECALL`, `EBREAK`, and `MRET` are not implemented.
  - **Interrupts and Exceptions**: Hardware interrupts (timer, external peripheral, software) and synchronous traps (illegal instruction, misaligned access) do not trap to an operating system vector; they currently execute as no-ops or invalid states.

---

### 3. Branch Prediction Mechanism
* **Current Implementation**: Static "Predict Not-Taken" branch architecture.
* **Limitations**:
  - Instructions following a branch are speculatively fetched assuming fall-through.
  - If a branch evaluates to **taken** in the `EX` stage, a **2-cycle pipeline penalty** is incurred while instructions in `IF/ID` and `ID/EX` are flushed.
  - Dynamic branch prediction structures such as a Branch Target Buffer (BTB), Branch History Table (BHT), or 2-bit saturating counters are absent.

---

### 4. Arithmetic Timing & Multi-Cycle Execution
* **Current Implementation**: Single-cycle combinational ALU and RV32M multiplier/divider in the `EX` stage.
* **Limitations**:
  - Integer division (`DIV`, `DIVU`, `REM`, `REMU`) and 64-bit multiplication products are computed combinatorially within the clock period of the `EX` stage.
  - While synthesizable and mathematically verified, on deep sub-micron ASIC technologies or high-frequency FPGAs (>150-200 MHz), this combinational divider forms the critical timing path, constraining maximum clock frequency ($F_{\max}$).
  - A production ASIC implementation would typically replace the single-cycle divider with an iterative multi-cycle Radix-2 or Radix-4 restoring/non-restoring hardware divider with pipeline stall handshakes.

---

### 5. Advanced ISA Extensions
* **Unsupported Extensions**:
  - **RV32A (Atomic Memory Operations)**: Load-Reserved (`LR.W`), Store-Conditional (`SC.W`), and Atomic Memory Operations (`AMOADD`, `AMOSWAP`, etc.) are not implemented.
  - **RV32F / RV32D (Single/Double Precision Floating-Point)**: Floating-point registers `f0-f31` and FP execution units are absent.
  - **RV32C (Compressed 16-bit Instructions)**: Instruction fetch strictly expects aligned 32-bit words; 16-bit RVC decompression is not supported.
  - **RV32V (Vector Operations)**: SIMD and vector pipelines are not implemented.

---

## 3. Recommended Architectural Upgrade Roadmap

1. **Phase A: Multi-Cycle Radix-4 Divider**:
   - Decouple integer division from the single-cycle ALU path into a multi-cycle iterative state machine that asserts a pipeline stall for 16-32 clock cycles during division, dramatically improving $F_{\max}$.
2. **Phase B: Machine-Mode Privileged CSR Unit**:
   - Implement basic Machine-mode CSRs (`mstatus`, `mepc`, `mcause`, `mtvec`) and trap controller to enable timer interrupt scheduling and exception handling.
3. **Phase C: Direct-Mapped or 2-Way Set-Associative Caches**:
   - Add Harvard architecture L1 instruction and data caches with valid/dirty tags and simple write-through policies.
4. **Phase D: Standard Bus Interface**:
   - Wrap the core in an open-source Wishbone or AXI4-Lite master interface for seamless SoC integration.
