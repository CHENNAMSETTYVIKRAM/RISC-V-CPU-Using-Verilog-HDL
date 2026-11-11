# Architectural Performance & CPI Comparison: Single-Cycle vs 5-Stage Pipeline

**Workbook Deliverables**:  
- **Activity 4.3**: Core performance comparison on Programs 3.2(a) and 3.2(c) with 5-line conclusion  
- **Activity 4.7**: Extended comparison covering all six programs with cycles, instructions, stalls, and CPI  
**Harness**: `scripts/verify.py` & Hardware Performance Telemetry Registers (`riscv_core_5stage.v`)  
**Simulation Disclosure**: All cycle counts were measured using the cycle-accurate architectural simulator. Native Verilog EDA simulation (ModelSim/Icarus) and physical FPGA synthesis were not performed due to toolchain unavailability in the host environment.

---

## 1. Activity 4.3: Core Performance Comparison & 5-Line Conclusion

As specified in Activity 4.3, benchmark programs **3.2(a) [Sum of 1 to 10]** and **3.2(c) [Array Maximum of 8 Words]** were evaluated on both the Single-Cycle RISC-V CPU (`riscv_single_cycle.v`) and the 5-Stage Pipelined RISC-V CPU (`riscv_core_5stage.v`).

### Activity 4.3 Comparison Table

| Program ID | Program Name | Instructions Retired ($N$) | Single-Cycle Clock Cycles | Single-Cycle CPI | 5-Stage Pipeline Clock Cycles | 5-Stage Stalls | 5-Stage Flushes | 5-Stage CPI |
|:---:|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **3.2(a)** | Sum of 1 to 10 | 32 | 32 | 1.000 | 54 | 10 | 10 | **1.688** |
| **3.2(c)** | Array Maximum (8 Words) | 18 | 18 | 1.000 | 31 | 6 | 3 | **1.722** |

### Activity 4.3: 5-Line Conclusion
1. The single-cycle architecture executes every instruction in exactly one clock cycle, achieving an ideal CPI of 1.000 across both programs.
2. The 5-stage pipelined architecture incurs initial pipeline fill latency (4 cycles) and pipeline flush penalties on taken conditional branches.
3. For Program 3.2(a), the backwards loop branch taken 9 times introduces branch misprediction flush penalties resulting in 54 cycles (CPI = 1.688).
4. For Program 3.2(c), memory loads combined with conditional maximum update branches cause load-use stalls and flushes totaling 31 cycles (CPI = 1.722).
5. In hardware implementations, the significantly shorter combinational path per stage permits a substantially higher clock frequency, offsetting the higher CPI to deliver net throughput improvement.

---

## 2. Activity 4.7: Extended Program Runs Across All Six Benchmarks

In Activity 4.7, all six programs—**Program 1 (Sum)**, **Program 2 (Fibonacci)**, **Program 3 (Array Max)**, **Program 4 (Bubble Sort of 8 Words)**, **Program 5 (Euclid GCD)**, and **Program 6 (Shift-and-Add Multiplication)**—were executed and measured.

### Activity 4.7 Complete Suite Telemetry Table

| Benchmark Program | Algorithmic Task | Instructions Retired ($N$) | Single-Cycle Cycles | Single-Cycle CPI | 5-Stage Cycles | 5-Stage Stalls | 5-Stage Flushes | Individual 5-Stage CPI |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Program 1** | Sum of 1 to 10 | 32 | 32 | 1.000 | 54 | 10 | 10 | 1.688 |
| **Program 2** | Fibonacci 10 Words in Memory | 64 | 64 | 1.000 | 83 | 8 | 8 | 1.297 |
| **Program 3** | Array Maximum (8 Words) | 18 | 18 | 1.000 | 31 | 6 | 3 | 1.722 |
| **Program 4** | In-place Bubble Sort (8 Words) | 235 | 235 | 1.000 | 334 | 62 | 34 | 1.421 |
| **Program 5** | Euclid GCD (48, 18) | 20 | 20 | 1.000 | 36 | 7 | 7 | 1.800 |
| **Program 6** | Software Shift-Add Mul (13x11) | 27 | 27 | 1.000 | 39 | 4 | 4 | 1.444 |
| **TOTALS** | **Cumulative Workload** | **396** | **396** | - | **577** | **97** | **66** | - |

---

## 3. Distinction: Aggregate CPI vs Average Individual CPI

When analyzing pipelined processor performance across a benchmark suite, it is vital to distinguish between the **Arithmetic Mean of Individual CPIs** and the **Aggregate Workload CPI**:

### 3.1 Arithmetic Mean of Individual CPIs
The arithmetic mean treats each benchmark equally regardless of execution length:
$$\text{CPI}_{\text{avg\_individual}} = \frac{1}{6} \sum_{i=1}^6 \text{CPI}_i = \frac{1.688 + 1.297 + 1.722 + 1.421 + 1.800 + 1.444}{6} = \mathbf{1.562}$$

### 3.2 Aggregate Workload CPI (True Execution Weighted CPI)
The aggregate CPI reflects the actual efficiency across the total instruction stream:
$$\text{CPI}_{\text{aggregate}} = \frac{\sum_{i=1}^6 \text{Cycles}_i}{\sum_{i=1}^6 \text{Instructions}_i} = \frac{577}{396} = \mathbf{1.457}$$

### 3.3 Key Architectural Insight
- The **Aggregate CPI (1.457)** is lower than the **Average Individual CPI (1.562)** because Program 4 (Bubble Sort, 235 instructions, CPI = 1.421) represents 59.3% of the total instructions executed across the suite.
- As program length increases, the fixed 4-cycle pipeline startup cost is amortized, and steady-state execution throughput dominates.

---

## 4. Verification Limitations & Synthesis Disclaimer

- **No Native Verilog Simulation**: All numbers were collected via the cycle-accurate Python architectural simulator (`scripts/verify.py`), not through native event-driven EDA tools (ModelSim / Icarus Verilog).
- **No Physical FPGA Synthesis**: No commercial or open-source logic synthesis tool (Xilinx Vivado, Intel Quartus, Yosys) was executed. Consequently, no physical place-and-route timing reports, Worst Negative Slack (WNS), or actual operating frequencies ($F_{max}$) are claimed.
