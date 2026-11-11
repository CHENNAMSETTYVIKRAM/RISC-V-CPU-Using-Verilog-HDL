# Architectural Performance & CPI Comparison: Single-Cycle vs 5-Stage Pipeline

**Workbook Deliverables**:  
- **Activity 4.3**: Core performance comparison on Programs 3.2(a) and 3.2(c) with 5-line conclusion  
- **Activity 4.7**: Extended comparison covering all six programs with cycles, instructions, stalls, and CPI  
**Harness**: `scripts/verify.py` & Hardware Performance Telemetry Registers (`riscv_core_5stage.v`)  
**Timing Disclosure**: All cycle counts are measured from cycle-accurate simulations. Theoretical frequency comparisons are based on analytical path estimation; physical FPGA synthesis timing was not run due to lack of an installed FPGA toolchain.

---

## 1. Activity 4.3: Core Performance Comparison & 5-Line Conclusion

As specified in Activity 4.3, benchmark programs **3.2(a) [Sum of 1 to 10]** and **3.2(c) [Array Maximum of 8 Words]** were executed on both the Single-Cycle RISC-V CPU (`riscv_single_cycle.v`) and the 5-Stage Pipelined RISC-V CPU (`riscv_core_5stage.v`).

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

In Activity 4.7, the remaining programs—**Program 4 (Bubble Sort of 8 Words)**, **Program 5 (Euclid GCD)**, and **Program 6 (Shift-and-Add Multiplication)**—along with **Program 2 (Fibonacci)** were executed on the pipelined CPU and verified against the single-cycle CPU.

### Activity 4.7 Complete Suite Telemetry Table

| Benchmark Program | Algorithmic Workload | Instructions Retired ($N$) | Single-Cycle Cycles | Single-Cycle CPI | 5-Stage Cycles | 5-Stage Stalls | 5-Stage Flushes | 5-Stage CPI |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Program 1** | Sum of 1 to 10 | 32 | 32 | 1.000 | 54 | 10 | 10 | 1.688 |
| **Program 2** | Fibonacci 10 Words in Memory | 64 | 64 | 1.000 | 83 | 8 | 8 | 1.297 |
| **Program 3** | Array Maximum (8 Words) | 18 | 18 | 1.000 | 31 | 6 | 3 | 1.722 |
| **Program 4** | In-place Bubble Sort (8 Words) | 235 | 235 | 1.000 | 334 | 62 | 34 | 1.421 |
| **Program 5** | Euclid GCD (48, 18) | 20 | 20 | 1.000 | 36 | 7 | 7 | 1.800 |
| **Program 6** | Software Shift-and-Add Mul (13x11) | 27 | 27 | 1.000 | 39 | 4 | 4 | 1.444 |
| **SUITE MEAN** | **Full Benchmark Suite Average** | **66.0** | **66.0** | **1.000** | **96.2** | **16.2** | **11.0** | **1.562** |

---

## 3. Analysis of Pipelining Overhead

The empirical average CPI for the 5-stage pipeline is **1.562**, compared to **1.000** for single-cycle execution:
1. **Compulsory Startup Overhead**: In short routines, the initial 4 cycles required to fill stages `IF`, `ID`, `EX`, `MEM`, and `WB` contribute noticeably to CPI ($\frac{4}{N}$).
2. **Branch Misprediction Penalty**: Branches resolve in the `EX` stage. When taken, two instructions fetched into `IF` and `ID` must be flushed (2 bubble cycles per taken branch). In iterative loops like Program 1 and Bubble Sort, branch flushes are the largest source of extra cycles.
3. **Load-Use Data Interlock**: When a register loaded by `LW` is immediately required by the following instruction's ALU operation, forwarding cannot supply the data in time, forcing a 1-cycle hardware bubble. Program 4 exhibits 62 stall cycles due to frequent load-compare patterns in inner-loop comparisons.
4. **Throughput Scaling**: For long-running programs (e.g. Program 4 with 235 instructions), the CPI stabilizes closer to 1.42, demonstrating that pipelining amortizes fixed startup overhead over larger instruction volumes.

---

## 4. Verification Limitations & Synthesis Disclaimer

- **No Synthesis Timing Fabrication**: No physical FPGA synthesis tool (such as Xilinx Vivado or Intel Quartus) was installed or executed in this environment. Therefore, no physical Worst Negative Slack (WNS) or maximum clock frequency ($F_{max}$) figures are reported as empirical fact.
- **Microarchitectural Theory**: Theoretically, a single-cycle datapath has a critical path equal to the sum of instruction memory, register file read, ALU, data memory, and register write setup time ($T_{single} \approx T_{IMEM} + T_{REG} + T_{ALU} + T_{DMEM} + T_{SETUP}$). In contrast, a 5-stage pipeline critical path is bounded by the slowest single stage plus register overhead ($\max(T_{stage}) + T_{CQ} + T_{SETUP}$). In real silicon, this allows pipelined architectures to run at 3x–4x higher clock frequency, which easily overcomes the 1.562 CPI penalty.
