# RISC-V 5-Stage Pipeline Hazard Analysis & Waveform Report

**Workbook Deliverables**:  
- **Activity 4.1**: Data Hazard Handling (Forwarding & Load-Use Stall)  
- **Activity 4.2**: Control Hazard Handling (Branch & Jump Flushing)  
- **Activity 4.5**: Hazard Waveform Report (Six Annotated Before/After Waveforms)  
**Implementation Modules**: `day4/src/riscv_hazard_unit.v`, `day4/src/riscv_core_5stage.v`  
**Test Programs**: `day4/src/hazard_test.s` / `.hex`, `day4/src/branch_flush_test.s` / `.hex`  

---

## 1. Executive Summary

In a 5-stage in-order RISC-V pipeline (`IF` -> `ID` -> `EX` -> `MEM` -> `WB`), data and control hazards arise due to instructions concurrently occupying overlapping stages. This report presents timing analyses and **six before/after Value Change Dump (VCD) waveforms** demonstrating:
1. Data dependency between consecutive arithmetic instructions (RAW hazard).
2. Load-use data dependency requiring a 1-cycle hardware interlock bubble.
3. Control hazard on taken branches requiring a 2-cycle pipeline flush.

---

## 2. Activity 4.5: Six Before/After Hazard Waveforms & Explanations

### 2.1 Hazard 1: Consecutive RAW Data Dependency

- **Code Sequence**:
  ```text
  addi x1, x0, 10    // I1: Computes x1 = 10 in EX, writes to regfile in WB
  addi x2, x1, 5     // I2: Needs x1 in EX immediately on next cycle
  ```

#### Waveform 1A: BEFORE FIX — No Forwarding
- **VCD File**: `day4/waves/hazard1_raw_before.vcd`
- **Signal States**:
  - At cycle 2, `I1` is in `EX` stage (`ex_alu_res = 10`), while `I2` is in `ID` reading register `x1`.
  - Since writeback occurs in cycle 4 (`WB` stage), register file entry `x1` still contains stale data `0`.
  - In cycle 3, `I2` enters `EX` with `rs1_val = 0`, computing `0 + 5 = 5` into `x2`.
  - **Verdict**: **FAILURE**. Result `x2 = 5` is mathematically corrupt (expected 15).

#### Waveform 1B: AFTER FIX — With EX-to-EX Forwarding
- **VCD File**: `day4/waves/hazard1_raw_after.vcd`
- **Signal States**:
  - The hazard unit detects: `ex_mem_reg_write == 1 && ex_mem_rd == id_ex_rs1 && ex_mem_rd != 0`.
  - It asserts `forward_a = 2'b10`, selecting `ex_mem_alu_result` (10) as ALU operand A instead of `rs1_val` (0).
  - In cycle 3, ALU computes `10 + 5 = 15` into `x2`.
  - **Verdict**: **SUCCESS**. Correct result `15` produced with **0 stall penalty**.

---

### 2.2 Hazard 2: Load-Use Data Hazard

- **Code Sequence**:
  ```text
  lw   x4, 0(x0)     // I1: Loads mem[0] (value = 25) into x4. Data available at end of MEM stage
  addi x5, x4, 10    // I2: Needs x4 in EX stage
  ```

#### Waveform 2A: BEFORE FIX — No Load-Use Stall Interlock
- **VCD File**: `day4/waves/hazard2_loaduse_before.vcd`
- **Signal States**:
  - `I1` (`LW`) is in `EX` stage calculating address. In the very next cycle, `I2` (`ADDI`) moves directly into `EX`.
  - But `LW` has not yet accessed data memory (still in `MEM` stage), so data `25` is physically unavailable.
  - Forwarding logic has no valid data to forward. Operand defaults to uninitialized/stale 0, computing `0 + 10 = 10` into `x5`.
  - **Verdict**: **FAILURE**. Result `x5 = 10` is corrupt (expected 35).

#### Waveform 2B: AFTER FIX — With 1-Cycle Hardware Interlock Stall
- **VCD File**: `day4/waves/hazard2_loaduse_after.vcd`
- **Signal States**:
  - The hazard detection unit identifies load-use condition:
    `id_ex_mem_read == 1 && (id_ex_rd == id_rs1 || id_ex_rd == id_rs2) && id_ex_rd != 0`.
  - In cycle 1: `stall_pc = 1`, `stall_if_id = 1`, and `flush_id_ex = 1` are asserted.
  - In cycle 2 (Stall Cycle): `PC` is held stationary, `IF/ID` register is preserved, and a bubble (`NOP`) is injected into `ID/EX`.
  - Meanwhile, `LW` completes stage `MEM`, loading data `25` into `mem_wb_mem_data`.
  - In cycle 3: `I2` enters `EX` stage. MEM-to-EX forwarding asserts `forward_a = 2'b01`, supplying loaded data `25`.
  - ALU computes `25 + 10 = 35` into `x5`.
  - **Verdict**: **SUCCESS**. Correct result `35` produced with exactly **1 stall cycle**.

---

### 2.3 Hazard 3: Control Hazard on Taken Branch

- **Code Sequence**:
  ```text
  0x10: beq  x1, x1, taken_branch   // Branch condition (1 == 1) evaluates taken in EX stage
  0x14: addi x3, x3, 999            // Speculatively fetched instruction 1
  0x18: addi x3, x3, 888            // Speculatively fetched instruction 2
  0x24: taken_branch: ...           // Target instruction
  ```

#### Waveform 3A: BEFORE FIX — No Pipeline Flush
- **VCD File**: `day4/waves/hazard3_branch_before.vcd`
- **Signal States**:
  - The branch evaluates taken in cycle 1 (`branch_taken = 1`, target PC redirected to `0x24`).
  - However, instructions at `0x14` and `0x18` have already entered `ID` and `IF` stages and are allowed to proceed through execution without suppression.
  - The speculative instructions execute, adding `999` and `888` to accumulator `x3`.
  - **Verdict**: **FAILURE**. Architectural state is corrupted by speculative path instructions that should never have executed.

#### Waveform 3B: AFTER FIX — With 2-Cycle Pipeline Flush
- **VCD File**: `day4/waves/hazard3_branch_after.vcd`
- **Signal States**:
  - The branch evaluates taken in stage `EX`. The hazard unit asserts synchronous flush control lines:
    `flush_if_id = 1` and `flush_id_ex = 1`.
  - On the next clock edge, the registers holding instructions `0x14` and `0x18` are cleared to `32'h00000013` (`NOP`).
  - Neither instruction performs register writeback or memory modification. Accumulator `x3` is preserved.
  - The PC updates to branch target `0x24`, which is cleanly fetched and executed.
  - **Verdict**: **SUCCESS**. Speculative instructions squashed with exactly **2 flush bubble cycles**.

---

## 3. Waveform Summary Matrix

| Waveform File | Hazard Type | Simulation Condition | Key Signals Tracked | Observed Behavior | Status |
|---|---|---|---|---|:---:|
| `hazard1_raw_before.vcd` | RAW Data Hazard | No Forwarding Unit | `clk`, `if_pc`, `id_instr`, `rs1_val`, `forward_a`, `ex_alu_res`, `x2` | Stale regfile read produces `x2 = 5` (corrupted) | **FAIL (Expected)** |
| `hazard1_raw_after.vcd` | RAW Data Hazard | With EX-to-EX Forwarding | `clk`, `if_pc`, `id_instr`, `rs1_val`, `forward_a`, `ex_alu_res`, `x2` | `forward_a = 2'b10` bypasses 10, computes `x2 = 15` | **PASS (Resolved)** |
| `hazard2_loaduse_before.vcd` | Load-Use Data Hazard | No Interlock Stall | `clk`, `pc`, `stall_pc`, `flush_id_ex`, `id_ex_mem_read`, `ex_alu_res`, `x5` | Load data not ready, operand reads 0 -> `x5 = 10` | **FAIL (Expected)** |
| `hazard2_loaduse_after.vcd` | Load-Use Data Hazard | With 1-Cycle Bubble Stall | `clk`, `pc`, `stall_pc`, `flush_id_ex`, `id_ex_mem_read`, `ex_alu_res`, `x5` | PC stalled, bubble injected, `x5 = 35` correctly computed | **PASS (Resolved)** |
| `hazard3_branch_before.vcd` | Control Hazard | No Branch Flush | `clk`, `pc`, `branch_taken`, `flush_if_id`, `flush_id_ex`, `x3` | Instructions at 0x14, 0x18 execute, corrupting `x3` | **FAIL (Expected)** |
| `hazard3_branch_after.vcd` | Control Hazard | With 2-Cycle Branch Flush | `clk`, `pc`, `branch_taken`, `flush_if_id`, `flush_id_ex`, `x3` | `flush_if_id=1, flush_id_ex=1` squash instructions to NOP | **PASS (Resolved)** |
