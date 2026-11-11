# Final Submission Status & Compliance Audit

**Student / Contributor**: Kalasalingam University Student  
**Assignment**: *Verilog RTL and RISC-V Practice Activities — 4-Day Intermediate Level Assignment* (Infoziant)  
**Trainer**: Yuvaraj Seenipandi, Infoziant  
**Date**: November 11, 2026  
**Git Commit**: `3ec47a9` (`Complete 4-Day Infoziant Assignment: 32 Activities, Waveforms, Testbenches, Reports`)  

---

## 1. Executive Summary & Status Overview

- **Workbook Activities**: 32 of 32 Activities implemented with synthesizable RTL and dedicated testbenches.
- **Python Verification Regression**: **39 of 39 Test Suites Passing (719 Checks, 0 Failures)**.
- **Static Linting**: **33 of 33 RTL source modules verified clean** with 0 errors and 0 inferred latches.
- **Native Verilog Simulation**: **NOT PERFORMED** (ModelSim / Icarus Verilog not installed on host).
- **Physical FPGA Synthesis**: **NOT PERFORMED** (Xilinx Vivado / Intel Quartus not installed on host).

---

## 2. Activity-by-Activity Implementation & Verification Status

### Day 1: RTL Building Blocks & Self-Checking Verification

| Activity | Topic / Task | Implementation Files | Testbench Files | Verification Evidence Status | Missing Verification Evidence |
|:---:|---|---|---|---|---|
| **1.1** | Parameterized ALU (32-bit default, flags) | `day1/src/alu.v`, `alu_parameterized.v` | `day1/tb/alu_tb.v` | Passed 30 vectors in Python model; VCD dumped | Native ModelSim/Icarus simulation not run |
| **1.2** | 8-bit Up/Down Counter (load, enable, flags) | `day1/src/counter.v`, `configurable_counter_8bit.v` | `day1/tb/counter_tb.v` | Passed counting & load checks in Python model | Native ModelSim/Icarus simulation not run |
| **1.3** | 32-bit Barrel Shifter (SLL, SRL, SRA 0..31) | `day1/src/shifter.v`, `riscv_barrel_shifter.v` | `day1/tb/shifter_tb.v` | Passed all shift amounts in Python model | Native ModelSim/Icarus simulation not run |
| **1.4** | 32x32 Register File (dual-read, bypass, x0=0) | `day1/src/regfile.v`, `riscv_regfile.v` | `day1/tb/regfile_tb.v` | Passed 200 random ops + bypass in Python model | Native ModelSim/Icarus simulation not run |
| **1.5** | 8-bit Adder/Subtractor (generate loop) | `day1/src/adder_sub.v`, `full_adder.v` | `day1/tb/adder_sub_tb.v` | Passed exhaustive combination check | Native ModelSim/Icarus simulation not run |
| **1.6** | Priority Encoder & Decoder (casez vs if-else) | `day1/src/encoder.v`, `decoder.v` | `day1/tb/encoder_tb.v`, `decoder_tb.v` | Passed priority & 1-hot checks; equivalence noted | Native ModelSim/Icarus simulation not run |
| **1.7** | Universal Shift Register & LFSR (255 states) | `day1/src/shiftreg.v`, `lfsr.v` | `day1/tb/shiftreg_tb.v`, `lfsr_tb.v` | Passed 4 shift modes & 255-state sequence check | Native ModelSim/Icarus simulation not run |
| **1.8** | Synchronizer, Edge Detector & Debouncer | `day1/src/debounce.v`, `edge_detect.v` | `day1/tb/debounce_tb.v`, `edge_detect_tb.v` | Passed bounce integration & pulse strobe checks | Native ModelSim/Icarus simulation not run |

### Day 2: FSM Controllers & Memory Design

| Activity | Topic / Task | Implementation Files | Testbench Files | Verification Evidence Status | Missing Verification Evidence |
|:---:|---|---|---|---|---|
| **2.1** | Sequence Detectors for '1011' (Moore & Mealy) | `day2/src/seq_moore.v`, `seq_mealy.v` | `day2/tb/seq_tb.v` | Passed 3 input streams; timing compared | Native ModelSim/Icarus simulation not run |
| **2.2** | Vending Machine (₹15 item, change, cancel) | `day2/src/vending.v` | `day2/tb/vending_tb.v` | State diagram in report; passed all transitions | Native ModelSim/Icarus simulation not run |
| **2.3** | Synchronous FIFO (16x8, full/empty flags) | `day2/src/fifo.v` | `day2/tb/fifo_tb.v` | Passed fill, drain, simultaneous r/w checks | Native ModelSim/Icarus simulation not run |
| **2.4** | Design Review (latch audit & fixes) | `report/DESIGN_REVIEW.md` | `scripts/lint_synth_check.py` | 33 RTL source files passed static lint | Physical FPGA synthesis not run |
| **2.5** | Traffic Light with Pedestrian Request | `day2/src/traffic.v` | `day2/tb/traffic_tb.v` | Passed vehicle timing & pedestrian walk checks | Native ModelSim/Icarus simulation not run |
| **2.6** | ATM Controller (PIN, balance, withdrawal) | `day2/src/atm.v` | `day2/tb/atm_tb.v` | State diagram in report; passed PIN & lockout | Native ModelSim/Icarus simulation not run |
| **2.7** | Round-Robin Arbiter (4 requesters) | `day2/src/arbiter.v` | `day2/tb/arbiter_tb.v` | Passed fair token rotation under constant requests | Native ModelSim/Icarus simulation not run |
| **2.8** | RAM, ROM ($readmemh) and Watchdog Timer | `day2/src/ram.v`, `rom.v`, `rom.hex`, `watchdog.v` | `day2/tb/ram_tb.v`, `rom_tb.v`, `watchdog_tb.v` | Passed RAM r/w, ROM $readmemh, and timeout/kick | Native ModelSim/Icarus simulation not run |

### Day 3: Extending Single-Cycle RISC-V CPU

| Activity | Topic / Task | Implementation Files | Testbench Files | Verification Evidence Status | Missing Verification Evidence |
|:---:|---|---|---|---|---|
| **3.1** | Instruction Extensions (ANDI, ORI, XORI, etc.) | `day3/src/riscv_single_cycle.v`, `riscv_control.v` | `day3/tb/cpu_tb.v` | Passed in Python model; control table documented | Native ModelSim/Icarus simulation not run |
| **3.2** | Commented Assembly Programs (1, 2, 3) | `programs/program1.hex`, `program2.hex`, `program3.hex` | `day3/tb/cpu_tb.v` | Comment line per instruction present; verified in Python | Native ModelSim/Icarus simulation not run |
| **3.3** | Self-Checking CPU Testbench | `day3/tb/cpu_tb.v` | `day3/tb/cpu_tb.v` | Testbench code present with PASS/FAIL checks | Native ModelSim/Icarus simulation not run |
| **3.4** | Waveform Analysis (Program 1 trace) | `report/WAVEFORM_ANALYSIS.md` | `day3/waves/single_cycle_programs.vcd` | Trace table & 8-line explanation documented | Live waveform screenshot from ModelSim |
| **3.5** | Branch & Jump Extensions (BNE, BLT, BGE, JALR) | `day3/src/riscv_alu.v`, `riscv_control.v` | `scripts/verify.py` | Passed signed comparison & return PC writing | Native ModelSim/Icarus simulation not run |
| **3.6** | More Assembly Programs (Bubble Sort 8W, GCD, Mul) | `programs/program4.hex`, `program5.hex`, `program6.hex` | `day3/tb/cpu_tb.v`, `scripts/verify.py` | Passed Bubble Sort 8W, GCD, Mul in Python model | Native ModelSim/Icarus simulation not run |
| **3.7** | Instruction Coverage Matrix | `coverage.md`, `report/INSTRUCTION_COVERAGE.md` | `scripts/verify.py` | 45 of 45 instructions verified in Python model | Hardware execution on silicon |
| **3.8** | Bug-Hunt Exercise (3 injected bugs) | `bugs.md`, `report/BUG_HUNT_REPORT.md` | `scripts/verify.py` | 3 bugs verified caught by assertions; RTL clean | Native ModelSim/Icarus simulation not run |

### Day 4: Pipeline Hazards, Analysis & Submission

| Activity | Topic / Task | Implementation Files | Testbench Files | Verification Evidence Status | Missing Verification Evidence |
|:---:|---|---|---|---|---|
| **4.1** | Data Hazard Handling (Forwarding & Stall) | `day4/src/riscv_core_5stage.v`, `hazard_test.s` | `day4/tb/cpu_pipe_tb.v` | Passed hazard_test in Python model | Native ModelSim/Icarus simulation not run |
| **4.2** | Control Hazard Handling (Branch/Jump Flush) | `day4/src/riscv_core_5stage.v`, `branch_flush_test.s` | `day4/tb/cpu_pipe_tb.v` | Passed branch_flush_test in Python model | Native ModelSim/Icarus simulation not run |
| **4.3** | Performance Comparison (Programs 3.2a & 3.2c) | `report/CPI_COMPARISON.md` | `scripts/verify.py` | Comparison table & 5-line conclusion documented | Native ModelSim/Icarus simulation not run |
| **4.4** | Git Submission | Git repo at working directory root | Git commit `3ec47a9` | Full project committed on branch `master` | Remote GitHub push URL |
| **4.5** | Hazard Waveform Report (6 Before/After Waves) | `report/PIPELINE_HAZARD_REPORT.md` | `day4/waves/hazard*.vcd` (6 files) | Six before/after VCD traces generated & analyzed | Live ModelSim waveform screenshots |
| **4.6** | Performance Telemetry Counters | `day4/src/riscv_core_5stage.v` | `day4/tb/cpu_pipe_tb.v`, `scripts/verify.py` | 4 hardware counters integrated and logged | Physical hardware performance counters |
| **4.7** | Extended Program Runs (All 6 Benchmarks) | `report/CPI_COMPARISON.md` | `day4/tb/cpu_pipe_tb.v`, `scripts/verify.py` | Full 6-program comparison table documented | Native ModelSim/Icarus simulation not run |
| **4.8** | Architecture Diagram & 5-Min Demo Notes | `report/ARCHITECTURE.md` | `ARCHITECTURE.md` | Mermaid pipeline diagram & demo notes documented | Video / live audio recording of demo |

---

## 3. Performance Summary & CPI Metrics

- **Total Instructions Retired Across Suite**: 396 instructions.
- **Total Pipelined Clock Cycles Across Suite**: 577 cycles.
- **Arithmetic Mean of Individual Program CPIs**: **1.562**
- **Aggregate Workload CPI ($\frac{\sum \text{Cycles}}{\sum \text{Instructions}}$)**: **1.457**
  *(Lower than arithmetic mean because long-running programs like Bubble Sort amortize fixed startup latency over 235 instructions).*

---

## 4. Known Environment Limitations

1. **Host EDA Tooling Absence**:
   - Neither ModelSim (`vsim`) nor Icarus Verilog (`iverilog`) is installed on the host operating system.
   - All tests were executed via the custom Python cycle-accurate simulator (`scripts/verify.py`).
2. **Synthesis Tooling Absence**:
   - Neither Xilinx Vivado nor Intel Quartus is installed.
   - Synthesizability was verified via static rule-based linting (`scripts/lint_synth_check.py`), confirming zero inferred latches and clean blocking/non-blocking discipline.
   - No FPGA timing closure, Worst Negative Slack (WNS), or actual hardware operating frequencies ($F_{max}$) are claimed as empirical measurements.
