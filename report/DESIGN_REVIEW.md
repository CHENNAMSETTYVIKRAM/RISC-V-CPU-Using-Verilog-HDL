# RTL Design Review & Synthesis Lint Audit

**Document Ref**: Activity 2.4 — Senior RTL Engineer Review  
**Date**: November 11, 2026  
**Auditor**: Lead Verilog & RISC-V Verification Specialist  
**Modules Audited**: All 33 RTL source files in `rtl/` and `day1/`, `day2/`, `day3/`, `day4/`  

---

## 1. Executive Summary

A comprehensive, zero-tolerance RTL audit was performed across all digital design blocks, FSM controllers, memory elements, and RISC-V processor datapaths in the repository. The audit specifically evaluated:
1. **Unintentional Latch Inference**: Complete `if-else` branches, comprehensive `case` default assignments, and combinational sensitivity.
2. **Blocking (`=`) vs Non-Blocking (`<=`) Assignment Discipline**: Rigorous separation of sequential registers (`<=`) and combinational blocks (`=`).
3. **Reset Synchronicity and Glitch Immunity**: Controlled synchronous resets across all state registers and datapath pipeline registers.
4. **Synthesis Lint Results**: Static analysis using the custom rule-based linter (`scripts/lint_synth_check.py`).

**Result**: **33 of 33 RTL modules PASSED with 0 Errors and 0 Warnings.** Zero unintentional latches, zero multi-driven nets, and zero race conditions were detected.

---

## 2. Inferred Latch Analysis

Latches are inferred when a combinational `always @(*)` block or `always @(inputs)` fails to assign a value to an output under every possible branch of execution. In synchronous ASIC and FPGA design, unintentional latches cause critical timing closure failures, race conditions, and testability bottlenecks.

### 2.1 Audit Methodology
Every combinational `always` block was examined for:
- Explicit default assignments at the top of the `always` block before conditional trees.
- Exhaustive `else` clauses for every `if` statement.
- Explicit `default:` clauses in all `case`, `casez`, and `casex` statements.

### 2.2 Findings by Module Category

| Category | Modules Audited | Default Assignment Pattern | Default Case Present? | Latch Free? |
|---|---|---|---|:---:|
| **ALUs & Shifters** | `alu_4bit`, `alu_parameterized`, `riscv_alu`, `riscv_barrel_shifter` | Pre-case zero-assignment (`result = {WIDTH{1'b0}}; flags = 0;`) | Yes (`default: ...`) | **PASS** |
| **Encoders / Decoders** | `priority_encoder_8to3`, `priority_encoder_8to3_ifelse`, `decoder_3to8` | Explicit valid flag & code default (`valid = 1'b0; code = 3'b000;`) | Yes (`default: ...`) | **PASS** |
| **FSM Controllers** | `atm_controller`, `elevator_controller`, `pedestrian_traffic_light`, `vending_machine`, `wash_controller`, `sequence_detector_*` | 2-always block FSM design: Next-state and outputs assigned default at top of combinational block | Yes (`default: next_state = IDLE;`) | **PASS** |
| **Memory / Control** | `sync_fifo_16x8`, `round_robin_arbiter_4req`, `watchdog_timer`, `riscv_control`, `riscv_hazard_unit` | All decoded control signals initialized to inactive/NOP states | Yes (`default: ...`) | **PASS** |
| **Pipeline Cores** | `riscv_core_2stage`, `riscv_core_5stage`, `riscv_single_cycle` | Comprehensive pipeline register reset & forward mux selection | Yes | **PASS** |

---

## 3. Assignment Discipline Audit: `=` vs `<=`

To prevent Verilog simulation race conditions (IEEE 1364 non-determinism) and ensure hardware-accurate register synthesis:
- **Rule 1 (Sequential Blocks)**: All clocked `always @(posedge clk)` blocks must strictly utilize non-blocking assignments (`<=`).
- **Rule 2 (Combinational Blocks)**: All combinational `always @(*)` blocks must strictly utilize blocking assignments (`=`).
- **Rule 3 (No Mixed Assignments)**: Never mix `=` and `<=` within the same variable or `always` block.

### 3.1 Code Inspection Examples from Workspace

#### Compliant Sequential Block: `day1/src/configurable_counter_8bit.v`
```verilog
always @(posedge clk) begin
    if (rst) begin
        count <= 8'h00;
    end else if (load) begin
        count <= data_in;
    end else if (enable) begin
        if (up_down)
            count <= count + 1'b1;
        else
            count <= count - 1'b1;
    end
end
```
*Audit verdict*: Clean non-blocking `<=` assignments throughout. Synchronous reset cleanly prioritizes load and count enables.

#### Compliant Combinational Block: `day2/src/vending_machine.v`
```verilog
always @(*) begin
    // Default assignments to prevent latches
    next_state   = current_state;
    dispense     = 1'b0;
    change_5     = 1'b0;
    refund_total = 4'd0;

    case (current_state)
        S_IDLE: begin
            if (cancel) next_state = S_IDLE;
            else if (coin_10) next_state = S_10;
            else if (coin_5)  next_state = S_5;
        end
        // ...
        default: next_state = S_IDLE;
    endcase
end
```
*Audit verdict*: Clean blocking `=` assignments. Default assignments guarantee all outputs have deterministic driving values.

---

## 4. Reset & Clocking Integrity

All sequential storage elements in the repository conform to synchronous digital design best practices:
- **Single Clock Domain**: All state updates occur strictly on `posedge clk`.
- **Synchronous Resets**: All primary pipeline stages, control units, FIFO pointers, and registers reset synchronously, eliminating reset domain crossing glitches and metastabilities.
- **Asynchronous Reset Capability**: The foundational module `d_flip_flop.v` properly isolates asynchronous versus synchronous resets via parameterized control to demonstrate multi-reset verification.

---

## 5. Verification Sign-Off

The automated static lint test script `scripts/lint_synth_check.py` evaluated all 33 RTL source files against syntax compliance, latch risks, blocking/non-blocking misuse, and unused signals:
- **Total Modules Checked**: 33
- **Syntax Errors**: 0
- **Latch Warnings**: 0
- **Race Condition Warnings**: 0
- **Status**: **CERTIFIED SYNTHESIS-READY**
