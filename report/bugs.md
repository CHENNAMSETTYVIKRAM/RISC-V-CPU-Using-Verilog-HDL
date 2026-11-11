# Activity 3.8: Bug-Hunt Exercise & Controlled Defect Injection Report

**Deliverable**: Activity 3.8 (`bugs.md`)  
**Objective**: Introduce 3 deliberate processor bugs, run test suite, record detection results, and confirm pristine RTL restoration.  

---

## 1. Summary of Bug Experiments

| Bug ID | Target Module | Introduced Defect | Expected Behavior | Observed Buggy Behavior | Caught by Testbench? |
|:---:|---|---|---|---|:---:|
| **BUG-1** | `riscv_imm_gen.v` | Zero-extended signed I-type immediate instead of sign-extending (`imm_out = {20'b0, instr[31:20]}`) | Negative immediates (e.g. `ADDI x2, x1, -4`) subtract 4 | `10 + 4092 = 4102` computed instead of 6 | **YES** (`test_full_rv32i_instruction_coverage:ADDI` failed) |
| **BUG-2** | `riscv_regfile.v` | Removed `waddr != 0` check, allowing architectural register `x0` to be written | `x0` permanently retains `0x00000000` | `x0` written with `42`, breaking all base-zero indexing | **YES** (`test_riscv_regfile` assertion violation: `x0 != 0`) |
| **BUG-3** | Datapath Branch Adder | Branch target calculated with zero-extended word offset instead of signed byte offset | Backwards loop branches jump backward | Jump target jumps forward past program boundary | **YES** (`Program 1` and `branch_flush_test` failed with invalid PC trap) |

---

## 2. Testbench Catch Evidence & Restoration

1. **Bug 1 (Immediate Sign-Extension)**:
   - Failing test: `test_full_rv32i_instruction_coverage`
   - Diagnostic trace: `ADDI x2, x1, -4: Got 0x00001006, Expected 0x00000006.`
   - Remediation: Restored sign-extension `{{20{instr[31]}}, instr[31:20]}`.
2. **Bug 2 (Writable Register x0)**:
   - Failing test: `test_riscv_regfile`
   - Diagnostic trace: `Assertion Violation: x0 hardwired invariant failed! Value = 0x0000002A.`
   - Remediation: Restored `if (we && waddr != 0)` guard.
3. **Bug 3 (Corrupted Branch Offset)**:
   - Failing test: `test_riscv_program1_sum`
   - Diagnostic trace: `Simulation trapped on invalid instruction fetch at PC = 0x0000100C (expected 0x0000000C).`
   - Remediation: Restored signed 13-bit B-type immediate calculation `pc + imm_b`.

All RTL source files verified restored and 100% clean.
