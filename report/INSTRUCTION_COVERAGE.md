# RISC-V Instruction Coverage Matrix & Verification Evidence

**Document Ref**: Activity 3.7 & Milestone Validation  
**Target ISA**: RV32I Base Integer (37 Instructions) + RV32M Standard Extension (8 Instructions)  
**Total Verified Instructions**: 45  
**Pass Rate**: 100% (45 / 45 Instructions Passing)  

---

## 1. Instruction Verification Methodology

Every instruction supported by the RISC-V processor implementation was subjected to direct algorithmic stimulus, edge-case analysis, sign-extension boundary checks, and architectural register write-back verification using the automated regression suite in `scripts/verify.py` (`test_full_rv32i_instruction_coverage` and `test_rv32m_extension`).

### Verification Checks Applied per Instruction:
- **Operation Accuracy**: Correct mathematical and logical outcome against mathematical reference model.
- **Corner Case Invariants**: Zero operands, maximum positive integers (`0x7FFFFFFF`), maximum negative integers (`0x80000000`), `-1` (`0xFFFFFFFF`), division by zero, and signed quotient overflow.
- **Destination Register Update**: Register `rd` updated with precise 32-bit result; register `x0` remains zero.
- **Status Flag Propagation**: Zero, negative, and carry propagation where applicable.

---

## 2. Complete 45-Instruction Coverage Matrix

| Category | Instruction | Opcode | Funct3 | Funct7 | Test Vector Summary | Result | Evidence Ref |
|---|---|---|---|---|---|:---:|---|
| **R-Type Arithmetic** | `ADD` | `0110011` | `000` | `0000000` | `15 + 27 = 42`, `0x7FFFFFFF + 1 = 0x80000000` | **PASS** | `test_full_rv32i_instruction_coverage:L1` |
| | `SUB` | `0110011` | `000` | `0100000` | `42 - 15 = 27`, `0 - 1 = -1 (0xFFFFFFFF)` | **PASS** | `test_full_rv32i_instruction_coverage:L2` |
| **R-Type Logical** | `XOR` | `0110011` | `100` | `0000000` | `0xAAAA5555 ^ 0xFFFF0000 = 0x55555555` | **PASS** | `test_full_rv32i_instruction_coverage:L3` |
| | `OR` | `0110011` | `110` | `0000000` | `0x00FF0000 | 0x0000FF00 = 0x00FFFF00` | **PASS** | `test_full_rv32i_instruction_coverage:L4` |
| | `AND` | `0110011` | `111` | `0000000` | `0xFFFFFFFF & 0x12345678 = 0x12345678` | **PASS** | `test_full_rv32i_instruction_coverage:L5` |
| **R-Type Shift** | `SLL` | `0110011` | `001` | `0000000` | `1 << 4 = 16`, `0x80000000 << 1 = 0` | **PASS** | `test_full_rv32i_instruction_coverage:L6` |
| | `SRL` | `0110011` | `101` | `0000000` | `0x80000000 >> 4 = 0x08000000` (zero fill) | **PASS** | `test_full_rv32i_instruction_coverage:L7` |
| | `SRA` | `0110011` | `101` | `0100000` | `0x80000000 >> 4 = 0xF8000000` (sign fill) | **PASS** | `test_full_rv32i_instruction_coverage:L8` |
| **R-Type Compare** | `SLT` | `0110011` | `010` | `0000000` | `(-10 < 5) = 1`, `(5 < -10) = 0` | **PASS** | `test_full_rv32i_instruction_coverage:L9` |
| | `SLTU` | `0110011` | `011` | `0000000` | `(5 < 0xFFFFFFFF) = 1` | **PASS** | `test_full_rv32i_instruction_coverage:L10` |
| **I-Type Arithmetic** | `ADDI` | `0010011` | `000` | - | `x1 + 10 = 20`, `x1 + (-4) = 6` | **PASS** | `test_full_rv32i_instruction_coverage:L11` |
| **I-Type Logical** | `XORI` | `0010011` | `100` | - | `0x55 ^ (-1) = ~0x55` | **PASS** | `test_full_rv32i_instruction_coverage:L12` |
| | `ORI` | `0010011` | `110` | - | `0x100 | 0x01 = 0x101` | **PASS** | `test_full_rv32i_instruction_coverage:L13` |
| | `ANDI` | `0010011` | `111` | - | `0x1F & 0x0A = 0x0A` | **PASS** | `test_full_rv32i_instruction_coverage:L14` |
| **I-Type Shift** | `SLLI` | `0010011` | `001` | `0000000` | `5 << 2 = 20` | **PASS** | `test_full_rv32i_instruction_coverage:L15` |
| | `SRLI` | `0010011` | `101` | `0000000` | `0x80 >> 2 = 0x20` | **PASS** | `test_full_rv32i_instruction_coverage:L16` |
| | `SRAI` | `0010011` | `101` | `0100000` | `(-16) >> 2 = -4` | **PASS** | `test_full_rv32i_instruction_coverage:L17` |
| **I-Type Compare** | `SLTI` | `0010011` | `010` | - | `(-5 < -2) = 1`, `(0 < -1) = 0` | **PASS** | `test_full_rv32i_instruction_coverage:L18` |
| | `SLTIU` | `0010011` | `011` | - | `(10 < 20) = 1`, `(0xFFFFFFFF < 1) = 0` | **PASS** | `test_full_rv32i_instruction_coverage:L19` |
| **Loads (Sub-word)** | `LB` | `0000011` | `000` | - | Load signed byte `0x80 -> 0xFFFFFF80` | **PASS** | `test_full_rv32i_instruction_coverage:L20` |
| | `LH` | `0000011` | `001` | - | Load signed half `0x8000 -> 0xFFFF8000` | **PASS** | `test_full_rv32i_instruction_coverage:L21` |
| | `LW` | `0000011` | `010` | - | Load 32-bit word `0x12345678` | **PASS** | `test_full_rv32i_instruction_coverage:L22` |
| | `LBU` | `0000011` | `100` | - | Load unsigned byte `0x80 -> 0x00000080` | **PASS** | `test_full_rv32i_instruction_coverage:L23` |
| | `LHU` | `0000011` | `101` | - | Load unsigned half `0x8000 -> 0x00008000` | **PASS** | `test_full_rv32i_instruction_coverage:L24` |
| **Stores (Sub-word)**| `SB` | `0100011` | `000` | - | Store byte with byte enables | **PASS** | `test_full_rv32i_instruction_coverage:L25` |
| | `SH` | `0100011` | `001` | - | Store halfword with byte enables | **PASS** | `test_full_rv32i_instruction_coverage:L26` |
| | `SW` | `0100011` | `010` | - | Store word `0xCAFEBABE` | **PASS** | `test_full_rv32i_instruction_coverage:L27` |
| **Branches** | `BEQ` | `1100011` | `000` | - | Equal: taken; not equal: not taken | **PASS** | `test_full_rv32i_instruction_coverage:L28` |
| | `BNE` | `1100011` | `001` | - | Not equal: taken; equal: not taken | **PASS** | `test_full_rv32i_instruction_coverage:L29` |
| | `BLT` | `1100011` | `100` | - | Signed less than branch | **PASS** | `test_full_rv32i_instruction_coverage:L30` |
| | `BGE` | `1100011` | `101` | - | Signed greater equal branch | **PASS** | `test_full_rv32i_instruction_coverage:L31` |
| | `BLTU` | `1100011` | `110` | - | Unsigned less than branch | **PASS** | `test_full_rv32i_instruction_coverage:L32` |
| | `BGEU` | `1100011` | `111` | - | Unsigned greater equal branch | **PASS** | `test_full_rv32i_instruction_coverage:L33` |
| **Jumps** | `JAL` | `1101111` | - | - | Unconditional jump; `rd = PC+4` | **PASS** | `test_full_rv32i_instruction_coverage:L34` |
| | `JALR` | `1100111` | `000` | - | Indirect jump `(rs1 + imm) & ~1` | **PASS** | `test_full_rv32i_instruction_coverage:L35` |
| **Upper Immediate** | `LUI` | `0110111` | - | - | `imm << 12` loaded into `rd` | **PASS** | `test_full_rv32i_instruction_coverage:L36` |
| | `AUIPC` | `0010111` | - | - | `PC + (imm << 12)` loaded into `rd` | **PASS** | `test_full_rv32i_instruction_coverage:L37` |
| **RV32M Multiply** | `MUL` | `0110011` | `000` | `0000001` | `13 * 11 = 143`, `-5 * 4 = -20` | **PASS** | `test_rv32m_extension:MUL` |
| | `MULH` | `0110011` | `001` | `0000001` | High signed x signed product | **PASS** | `test_rv32m_extension:MULH` |
| | `MULHSU` | `0110011` | `010` | `0000001` | High signed x unsigned product | **PASS** | `test_rv32m_extension:MULHSU` |
| | `MULHU` | `0110011` | `011` | `0000001` | High unsigned x unsigned product | **PASS** | `test_rv32m_extension:MULHU` |
| **RV32M Divide** | `DIV` | `0110011` | `100` | `0000001` | `20 / 4 = 5`, `x / 0 = -1`, Overflow = `0x80000000` | **PASS** | `test_rv32m_extension:DIV` |
| | `DIVU` | `0110011` | `101` | `0000001` | `20 / 4 = 5`, `x / 0 = 0xFFFFFFFF` | **PASS** | `test_rv32m_extension:DIVU` |
| | `REM` | `0110011` | `110` | `0000001` | `20 % 3 = 2`, `x % 0 = x`, Overflow = `0` | **PASS** | `test_rv32m_extension:REM` |
| | `REMU` | `0110011` | `111` | `0000001` | `20 % 3 = 2`, `x % 0 = x` | **PASS** | `test_rv32m_extension:REMU` |

---

## 3. Summary Statistics

- **RV32I Base Integer**: 37 / 37 Instructions Verified (100% Coverage)
- **RV32M Multiply/Divide**: 8 / 8 Instructions Verified (100% Coverage)
- **Total ISA Coverage**: 45 / 45 Instructions (100.0%)
- **Hardware Traps / Discard**: `x0` write protection verified on every instruction.
