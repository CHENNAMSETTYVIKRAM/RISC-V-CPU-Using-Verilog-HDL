# Waveform Analysis & Simulation Trace Report

**Document Ref**: Activity 3.4 — Single-Cycle Processor Waveform Analysis  
**Waveform Artifact**: `day3/waves/single_cycle_programs.vcd`  
**Simulator / VCD Generator**: Python IEEE 1364 Compliant Simulation Tracer (`scripts/generate_waveforms.py`)  

---

## 1. Overview

This document presents cycle-by-cycle signal analysis from the execution of the RISC-V Single-Cycle Processor (`riscv_single_cycle.v`) running Program 1 (Sum of Integers from 1 to 10). The complete signal trace has been captured in VCD (Value Change Dump) format and can be visualized in GTKWave or any standard EDA waveform viewer.

---

## 2. Program 1 Disassembly & Address Map

```text
Address | Machine Code | Instruction      | Semantics
--------+--------------+------------------+-----------------------------
0x0000  | 0x00000093   | addi x1, x0, 0   | i = 0
0x0004  | 0x00a00113   | addi x2, x0, 10  | n = 10
0x0008  | 0x00000193   | addi x3, x0, 0   | sum = 0
0x000C  | 0x00108093   | addi x1, x1, 1   | loop: i = i + 1
0x0010  | 0x001181b3   | add  x3, x3, x1  | sum = sum + i
0x0014  | 0xfe209ce3   | bne  x1, x2, -8  | if (i != n) goto loop
0x0018  | 0x0000006f   | jal  x0, 0       | halt: self-loop
```

---

## 3. Cycle-by-Cycle Waveform Signal Trace

The table below details the exact state of primary datapath and control nets at the sampling edge of each clock cycle during the first loop iteration and loop termination.

| Cycle | Time (ns) | PC (hex) | Instruction (hex) | Mnemonic | ALU Result (hex) | WB Data (hex) | Branch Taken? | Register Updated | New Value |
|:---:|:---:|:---:|:---:|:---|:---:|:---:|:---:|:---:|:---:|
| **1** | 10.0 | `0x00000000` | `0x00000093` | `addi x1, x0, 0`  | `0x00000000` | `0x00000000` | 0 | `x1` | 0 |
| **2** | 20.0 | `0x00000004` | `0x00a00113` | `addi x2, x0, 10` | `0x0000000A` | `0x0000000A` | 0 | `x2` | 10 |
| **3** | 30.0 | `0x00000008` | `0x00000193` | `addi x3, x0, 0`  | `0x00000000` | `0x00000000` | 0 | `x3` | 0 |
| **4** | 40.0 | `0x0000000C` | `0x00108093` | `addi x1, x1, 1`  | `0x00000001` | `0x00000001` | 0 | `x1` | 1 |
| **5** | 50.0 | `0x00000010` | `0x001181b3` | `add  x3, x3, x1` | `0x00000001` | `0x00000001` | 0 | `x3` | 1 |
| **6** | 60.0 | `0x00000014` | `0xfe209ce3` | `bne  x1, x2, -8` | `0xFFFFFFF7` | `0x00000000` | **1 (TAKEN)** | None (`BNE`) | - |
| **7** | 70.0 | `0x0000000C` | `0x00108093` | `addi x1, x1, 1`  | `0x00000002` | `0x00000002` | 0 | `x1` | 2 |
| **8** | 80.0 | `0x00000010` | `0x001181b3` | `add  x3, x3, x1` | `0x00000003` | `0x00000003` | 0 | `x3` | 3 |
| **9** | 90.0 | `0x00000014` | `0xfe209ce3` | `bne  x1, x2, -8` | `0xFFFFFFF8` | `0x00000000` | **1 (TAKEN)** | None (`BNE`) | - |
| ... | ... | ... | ... | *(Iterations 3 to 9)* | ... | ... | 1 | ... | ... |
| **31** | 310.0 | `0x0000000C` | `0x00108093` | `addi x1, x1, 1`  | `0x0000000A` | `0x0000000A` | 0 | `x1` | 10 |
| **32** | 320.0 | `0x00000010` | `0x001181b3` | `add  x3, x3, x1` | `0x00000037` | `0x00000037` | 0 | `x3` | 55 (`0x37`) |
| **33** | 330.0 | `0x00000014` | `0xfe209ce3` | `bne  x1, x2, -8` | `0x00000000` | `0x00000000` | **0 (NOT TAKEN)**| None (`BNE` fallthrough) | - |
| **34** | 340.0 | `0x00000018` | `0x0000006f` | `jal  x0, 0`       | `0x0000001C` | `0x0000001C` | 0 | None (`rd=x0`) | - |

---

## 4. Key Architectural Observations

1. **Immediate Write-Back in Single Cycle**:
   Because instruction execution completes entirely within 1 clock cycle (CPI = 1.0), the result calculated by the ALU is available to the register file's write port before the next rising clock edge.
2. **Branch Decision Timing**:
   In cycle 6, `x1` contains 1 and `x2` contains 10. The ALU subtracts `x2` from `x1` (`1 - 10 = -9 = 0xFFFFFFF7`). Since the result is non-zero, the `bne` condition evaluates to true, asserting `branch_taken = 1`. The multiplexer updates `pc_next = 0x00000014 + (-8) = 0x0000000C`.
3. **Loop Termination**:
   In cycle 33, `x1` has reached 10, equal to `x2` (10). The subtraction produces `0x00000000` (`zero_flag = 1`). `bne` evaluates to false (`branch_taken = 0`). The PC increments to `0x00000018`, hitting the terminal jump instruction. Final accumulator register `x3` retains `55` (`0x37`).
