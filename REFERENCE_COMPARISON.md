# Reference Repository Comparison & Technical Evaluation

## 1. Reference Repository Analysis (`Jayakrushna0304/Risk_Verilog`)

A thorough inspection of the reference repository reveals 4 main domains:
1. **RISC-V Architectures**:
   - `basic_2stage_riscv_verilog/`: 2-stage (IF, EX) supporting ADD, SUB, AND, OR, ADDI, LW, SW, BEQ.
   - `RISCV_5Stage_Processor/`: 5-stage (IF, ID, EX, MEM, WB) with load-use stall, forwarding unit, branch flush, and basic instruction set.
   - `RISCV_7Stage_processor/`: 7-stage (IF, ID, RR, EX1, EX2, MEM, WB). *Defect note: Missing forwarding and hazard detection units, incomplete branch flushing.*
   - `Instruction_Extensions/`: Single-cycle CPU supporting ANDI, ORI, XORI, SLTI, SLLI, SRLI, LUI, JAL.
   - `RISCV_Assembly_Programs/`: Assembly programs for Sum 1..N, Fibonacci, and Array Max.
   - `regfile/`: 32x32 register file with write-to-read bypass. *Defect note: Uses initial block rather than deterministic reset.*
   - `shifter/`: 32-bit barrel shifter supporting logical left, logical right, arithmetic right shifts.
2. **Digital Design Components**:
   - 8-bit Carry Adder/Subtractor (`Carry AdderSubtractor/`)
   - Configurable Counter with load/up-down (`counter/`)
   - D Flip-Flop (`D Flip-Flop/`)
   - Edge Detector and Debouncer (`Edge Detector and Debouncer/`)
   - LFSR and Universal Shift Register (`LFSR and Shift Register/`)
   - Priority Encoder & 3-to-8 Decoder (`Priority Encoder and Decoder/`)
3. **FSM-Based Applications**:
   - 4-Floor Automatic Elevator Controller (`4Floor_Automatic_Elevator/`)
   - ATM Controller with PIN verification and transactions (`ATM_Controller_Using_FSM/`)
   - Pedestrian Traffic Light with timers (`Traffic_Light_Pedestrian/`)
   - Multi-Coin Vending Machine with change/refund (`Q2.2_Vending_Machine/`)
   - Mealy & Moore Sequence Detectors for 1011 (`Q2.1_Sequence_Detector/`)
   - Washing Machine Controller (`FSM/washing.sv`)
4. **Memory & Architecture Components**:
   - Synchronous RAM (`RAM_ROM_Watchdog/ram.v`)
   - ROM with hex initialization (`RAM_ROM_Watchdog/rom.v`)
   - Watchdog Timer with kick and reset pulse (`RAM_ROM_Watchdog/watchdog.v`)
   - Synchronous FIFO (`Synchronous_FIFO/fifo.v`)
   - Round-Robin Arbiter with rotating priority (`Round_Robin_Arbiter/arbiter.v`)

---

## 2. Feature-by-Feature Gap Analysis

| Feature / Module | Existing Repo Status | Reference Repo Status | Gap Identified | Priority | Action Plan |
|---|---|---|---|---|---|
| **Pipelined 5-Stage RISC-V CPU** | Missing | Present (subset: ADD, SUB, AND, OR, ADDI, LW, SW, BEQ) | Reference lacks full RV32I instructions (SLT, SLTU, XOR, shifts, immediate shifts, branches BNE/BLT/BGE, jumps JAL/JALR, LUI, AUIPC). | **P0** | Implement full-featured 5-stage RV32I core with complete forwarding, load-use stall, branch/jump handling, and comprehensive verification. |
| **2-Stage RISC-V CPU** | Missing | Present (subset) | Reference implementation has basic IF-EX with separate I/D memories. | **P1** | Implement clean, verified 2-stage RISC-V CPU with deterministic reset and strict x0=0 invariant. |
| **7-Stage RISC-V CPU** | Missing | Present but flawed (No hazard detection, no forwarding, broken branch flush) | Stale register reads on RAW dependencies, incorrect multi-cycle flush. | **P2** | Document reference defects; provide architecturally sound multi-stage pipeline design with correct hazard stalls. |
| **RV32I Instruction Extensions** | Missing | Present in single-cycle demo (ANDI, ORI, XORI, SLTI, SLLI, SRLI, LUI, JAL) | Existing repo lacks RV32I instruction set decode and execution. | **P1** | Integrate all RV32I base instructions into unified 32-bit ALU, decoder, and processor cores. |
| **RISC-V 32x32 Register File** | Missing | Present (lacks reset port, uses `initial` block) | Need synthesizable register file with active-high synchronous reset, dual read, single write, bypass logic, and x0 tied to 0. | **P0** | Implement production-quality `riscv_regfile.v` with reset, bypass, and self-checking testbench. |
| **32-Bit Barrel Shifter** | Missing | Present (SLL, SRL, SRA) | Missing in existing repo. | **P1** | Implement robust `riscv_barrel_shifter.v` supporting SLL, SRL, and signed SRA. |
| **RV32I Assembly Benchmark Programs** | Missing | Present (Sum 1..10, Fibonacci, Array Max) | Missing in existing repo. | **P1** | Port and verify all 3 assembly programs and create automated simulation tests verifying memory and register outputs. |
| **Carry Adder/Subtractor (8-bit)** | Missing (only 4-bit adder present) | Present (`adder_sub.v` with mode, carry, overflow) | Existing only has 4-bit ripple adder. | **P1** | Implement 8-bit parameterizable carry adder/subtractor with overflow detection and self-checking testbench. |
| **Configurable Counter (8-bit)** | Missing | Present (load, enable, up/down) | Missing in existing repo. | **P1** | Implement configurable up/down counter with synchronous load and clear. |
| **D Flip-Flop Variants** | Missing | Present (basic D-FF without reset) | Reference lacks reset. Standard digital design requires sync and async reset variants. | **P2** | Implement D flip-flop with active-high synchronous reset and enable. |
| **Edge Detector & Debouncer** | Missing | Present (`edge_detect.v`, `input_sync.v`, `debounce.v`) | Missing in existing repo. | **P1** | Implement 2-stage synchronizer, posedge/negedge detector, and parameterizable debouncer. |
| **LFSR & Universal Shift Register** | Missing | Present (`lfsr.v`, `shiftreg.v`) | Missing in existing repo. | **P1** | Implement 8-bit LFSR (maximal-length polynomial) and 4-mode universal shift register (Hold, SLL, SLR, Parallel Load). |
| **Priority Encoder & 3-to-8 Decoder** | Missing | Present (`encoder.v`, `decoder.v`) | Missing in existing repo. | **P1** | Implement 8-to-3 priority encoder with valid flag and active-high enable 3-to-8 decoder. |
| **Elevator Controller (4-Floor)** | Missing | Present (4 floors, door timer, emergency) | Missing in existing repo. | **P1** | Implement 4-floor elevator FSM with door timer, emergency halt, and self-checking testbench. |
| **ATM Controller FSM** | Missing | Present (PIN check, balance, withdraw, deposit, eject) | Missing in existing repo. | **P1** | Implement realistic ATM FSM with 3-attempt PIN lockout, cash dispensing, and balance tracking. |
| **Pedestrian Traffic Light FSM** | Missing | Present (car red/yellow/green, walk, timers) | Missing in existing repo. | **P1** | Implement timed pedestrian traffic light controller with request latching and safety interlocks. |
| **Vending Machine FSM** | Missing | Present (coin5, coin10, dispense, change, cancel) | Missing in existing repo. | **P1** | Implement multi-coin vending controller with item dispense, change return, and refund. |
| **Sequence Detectors (Mealy & Moore)** | Missing | Present (1011 sequence with overlap) | Missing in existing repo. | **P1** | Implement both Mealy and Moore 1011 sequence detectors with overlap capability and comparative testbench. |
| **Washing Machine Controller** | Present (`wash_controller.v`, Moore FSM) | Present (`washing.sv`, SystemVerilog) | Existing Verilog implementation is already well-structured. | **Preserve** | Keep existing `rtl/wash_controller.v` as primary; add SystemVerilog version as complementary reference. |
| **Synchronous RAM (16x8)** | Missing | Present (`ram.v` single-port) | Missing in existing repo. | **P1** | Implement clean synchronous single-port RAM module with read-during-write documentation. |
| **Synchronous ROM (16x8)** | Missing | Present (`rom.v` with `$readmemh`) | Missing in existing repo. | **P1** | Implement synchronous ROM with memory initialization file support and fallback contents. |
| **Synchronous FIFO** | Missing | Present (`fifo.v` with count, full, empty) | Missing in existing repo. | **P1** | Implement robust synchronous FIFO with pointer management, full/empty flags, and overflow/underflow protection. |
| **Round-Robin Arbiter** | Missing | Present (`arbiter.v` 4-requester rotating priority) | Missing in existing repo. | **P1** | Implement 4-port round-robin arbiter with fair rotating priority and grant persistence. |
| **Watchdog Timer** | Missing | Present (`watchdog.v` with kick, timeout pulse) | Missing in existing repo. | **P1** | Implement parameterizable watchdog timer with reset pulse output and kick input. |
| **Automated Verification Harness** | Missing (manual command steps only) | Missing (only manual scripts) | Both repos lack an end-to-end automated regression test runner. | **P0** | Implement Python-based automated regression verification suite and batch scripts to compile, execute, and report test results. |

---

## 3. Reference Architectural Limitations & Defects Avoided

1. **Reference 7-Stage Pipeline RAW Hazard Bug**:
   The reference `riscv_7stage.v` has no forwarding unit or hazard detection unit. Instructions with back-to-back register dependencies read stale data because writeback occurs 5 cycles after instruction decode. We will document this limitation honestly and provide a properly forwarded 5-stage pipeline as the primary robust CPU.
2. **Reference Branch Flush Incompleteness**:
   In `riscv_7stage.v`, when a branch is taken, only the `if_id` register is cleared, leaving partially executed instructions in subsequent stages to cause corrupt state. Our processor designs properly flush all intervening speculative pipeline registers.
3. **Register File Reset Omission**:
   The reference `regfile.v` relies purely on simulation `initial` blocks. In synthesizable ASIC/FPGA workflows, registers power up with undefined states (`X`). Our `riscv_regfile.v` provides an active-high synchronous reset to guarantee deterministic hardware initialization.
4. **Subtractor Borrow Inconsistency**:
   In some toy ALU implementations, subtract borrow is computed without sign clarity. Our ALU uses standard two's-complement arithmetic with proper carry/borrow and signed overflow (`V`) calculation.
