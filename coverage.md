# RISC-V Instruction Coverage Matrix

**Deliverable**: Activity 3.7 (`coverage.md`)  
**Target Core**: RV32I Base Integer ISA + RV32M Standard Extension  
**Verification Harness**: `scripts/verify.py` & Directed HDL Testbenches  
**Total Supported Instructions**: 45  
**Coverage**: 100.0% (45 / 45 Passing)  

---

| Category | Instruction | Opcode | Funct3 | Funct7 | Exercising Test Case | Result |
|---|---|---|---|---|---|:---:|
| **R-Type Arithmetic** | `ADD` | `0110011` | `000` | `0000000` | `test_full_rv32i_instruction_coverage:ADD` | **PASS** |
| | `SUB` | `0110011` | `000` | `0100000` | `test_full_rv32i_instruction_coverage:SUB` | **PASS** |
| **R-Type Logical** | `XOR` | `0110011` | `100` | `0000000` | `test_full_rv32i_instruction_coverage:XOR` | **PASS** |
| | `OR` | `0110011` | `110` | `0000000` | `test_full_rv32i_instruction_coverage:OR` | **PASS** |
| | `AND` | `0110011` | `111` | `0000000` | `test_full_rv32i_instruction_coverage:AND` | **PASS** |
| **R-Type Shifts** | `SLL` | `0110011` | `001` | `0000000` | `test_full_rv32i_instruction_coverage:SLL` | **PASS** |
| | `SRL` | `0110011` | `101` | `0000000` | `test_full_rv32i_instruction_coverage:SRL` | **PASS** |
| | `SRA` | `0110011` | `101` | `0100000` | `test_full_rv32i_instruction_coverage:SRA` | **PASS** |
| **R-Type Compares**| `SLT` | `0110011` | `010` | `0000000` | `test_full_rv32i_instruction_coverage:SLT` | **PASS** |
| | `SLTU` | `0110011` | `011` | `0000000` | `test_full_rv32i_instruction_coverage:SLTU` | **PASS** |
| **I-Type Arithmetic**| `ADDI` | `0010011` | `000` | - | `test_full_rv32i_instruction_coverage:ADDI` | **PASS** |
| **I-Type Logical** | `XORI` | `0010011` | `100` | - | `test_full_rv32i_instruction_coverage:XORI` | **PASS** |
| | `ORI` | `0010011` | `110` | - | `test_full_rv32i_instruction_coverage:ORI` | **PASS** |
| | `ANDI` | `0010011` | `111` | - | `test_full_rv32i_instruction_coverage:ANDI` | **PASS** |
| **I-Type Shifts** | `SLLI` | `0010011` | `001` | `0000000` | `test_full_rv32i_instruction_coverage:SLLI` | **PASS** |
| | `SRLI` | `0010011` | `101` | `0000000` | `test_full_rv32i_instruction_coverage:SRLI` | **PASS** |
| | `SRAI` | `0010011` | `101` | `0100000` | `test_full_rv32i_instruction_coverage:SRAI` | **PASS** |
| **I-Type Compares**| `SLTI` | `0010011` | `010` | - | `test_full_rv32i_instruction_coverage:SLTI` | **PASS** |
| | `SLTIU` | `0010011` | `011` | - | `test_full_rv32i_instruction_coverage:SLTIU` | **PASS** |
| **Loads (Sub-Word)**| `LB` | `0000011` | `000` | - | `test_full_rv32i_instruction_coverage:LB` | **PASS** |
| | `LH` | `0000011` | `001` | - | `test_full_rv32i_instruction_coverage:LH` | **PASS** |
| | `LW` | `0000011` | `010` | - | `test_full_rv32i_instruction_coverage:LW` | **PASS** |
| | `LBU` | `0000011` | `100` | - | `test_full_rv32i_instruction_coverage:LBU` | **PASS** |
| | `LHU` | `0000011` | `101` | - | `test_full_rv32i_instruction_coverage:LHU` | **PASS** |
| **Stores (Sub-Word)**| `SB` | `0100011` | `000` | - | `test_full_rv32i_instruction_coverage:SB` | **PASS** |
| | `SH` | `0100011` | `001` | - | `test_full_rv32i_instruction_coverage:SH` | **PASS** |
| | `SW` | `0100011` | `010` | - | `test_full_rv32i_instruction_coverage:SW` | **PASS** |
| **Conditional Branches**| `BEQ` | `1100011` | `000` | - | `test_full_rv32i_instruction_coverage:BEQ` | **PASS** |
| | `BNE` | `1100011` | `001` | - | `test_full_rv32i_instruction_coverage:BNE` | **PASS** |
| | `BLT` | `1100011` | `100` | - | `test_full_rv32i_instruction_coverage:BLT` | **PASS** |
| | `BGE` | `1100011` | `101` | - | `test_full_rv32i_instruction_coverage:BGE` | **PASS** |
| | `BLTU` | `1100011` | `110` | - | `test_full_rv32i_instruction_coverage:BLTU` | **PASS** |
| | `BGEU` | `1100011` | `111` | - | `test_full_rv32i_instruction_coverage:BGEU` | **PASS** |
| **Unconditional Jumps**| `JAL` | `1101111` | - | - | `test_full_rv32i_instruction_coverage:JAL` | **PASS** |
| | `JALR` | `1100111` | `000` | - | `test_full_rv32i_instruction_coverage:JALR` | **PASS** |
| **Upper Immediates**| `LUI` | `0110111` | - | - | `test_full_rv32i_instruction_coverage:LUI` | **PASS** |
| | `AUIPC` | `0010111` | - | - | `test_full_rv32i_instruction_coverage:AUIPC` | **PASS** |
| **RV32M Hardware Math**| `MUL` | `0110011` | `000` | `0000001` | `test_rv32m_extension:MUL` | **PASS** |
| | `MULH` | `0110011` | `001` | `0000001` | `test_rv32m_extension:MULH` | **PASS** |
| | `MULHSU` | `0110011` | `010` | `0000001` | `test_rv32m_extension:MULHSU` | **PASS** |
| | `MULHU` | `0110011` | `011` | `0000001` | `test_rv32m_extension:MULHU` | **PASS** |
| | `DIV` | `0110011` | `100` | `0000001` | `test_rv32m_extension:DIV` (incl. div-by-0) | **PASS** |
| | `DIVU` | `0110011` | `101` | `0000001` | `test_rv32m_extension:DIVU` (incl. div-by-0) | **PASS** |
| | `REM` | `0110011` | `110` | `0000001` | `test_rv32m_extension:REM` (incl. rem-by-0) | **PASS** |
| | `REMU` | `0110011` | `111` | `0000001` | `test_rv32m_extension:REMU` (incl. rem-by-0) | **PASS** |
