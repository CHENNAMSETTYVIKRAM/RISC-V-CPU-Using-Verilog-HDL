# RISC-V 32-Bit Instruction Control Decode Table

**Document Ref**: Activity 3.3 & Activity 3.7  
**Architecture**: RV32I Base Integer ISA (37 Instructions) + RV32M Standard Extension (8 Instructions)  
**Total Decoded Instructions**: 45  

---

## 1. Control Unit Signal Definitions

The central control unit (`riscv_control.v`) and execution datapath decode each 32-bit instruction word into the following synchronous pipeline signals:

- **RegWrite**: Asserts `1` when the instruction writes a calculated result or loaded memory word into destination register `rd`. (Disabled if `rd == x0`).
- **ALUSrc**: Selects the second operand of the ALU (`0` = `rs2` register data, `1` = sign-extended immediate).
- **MemRead**: Asserts `1` for data memory load instructions (`LB`, `LH`, `LW`, `LBU`, `LHU`).
- **MemWrite**: Asserts `1` for data memory store instructions (`SB`, `SH`, `SW`).
- **MemToReg**: Selects write-back data multiplexer (`0` = ALU / multiplier result, `1` = data memory read word).
- **Branch**: Asserts `1` for conditional branch instructions (`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`).
- **Jump**: Asserts `1` for unconditional jump instructions (`JAL`, `JALR`).
- **JALR**: Differentiates `JALR` (target = `rs1 + imm`) from `JAL` (target = `pc + imm`).
- **LUI / AUIPC**: Selects special immediate arithmetic paths for upper immediate loading.
- **M_Valid**: Asserts `1` when an RV32M standard extension operation is requested (`funct7 == 7'b0000001`).
- **ALUControl [3:0]**: Encodes the ALU core operation:
  - `4'b0000`: ADD
  - `4'b0001`: SUB
  - `4'b0010`: SLL (Shift Left Logical)
  - `4'b0011`: SLT (Set Less Than Signed)
  - `4'b0100`: SLTU (Set Less Than Unsigned)
  - `4'b0101`: XOR
  - `4'b0110`: SRL (Shift Right Logical)
  - `4'b0111`: SRA (Shift Right Arithmetic)
  - `4'b1000`: OR
  - `4'b1001`: AND
  - `4'b1100`: PASS_B (for LUI)

---

## 2. Complete 45-Instruction Control Matrix

| Instruction | Type | Opcode | Funct3 | Funct7 | RegWrite | ALUSrc | MemRead | MemWrite | MemToReg | Branch | Jump | ALUControl | M_Valid | Description |
|---|---|---|---|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|---|
| **ADD** | R | `0110011` | `000` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0000` (ADD) | 0 | Integer Addition |
| **SUB** | R | `0110011` | `000` | `0100000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0001` (SUB) | 0 | Integer Subtraction |
| **SLL** | R | `0110011` | `001` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0010` (SLL) | 0 | Shift Left Logical |
| **SLT** | R | `0110011` | `010` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0011` (SLT) | 0 | Set Less Than (Signed) |
| **SLTU** | R | `0110011` | `011` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0100` (SLTU) | 0 | Set Less Than (Unsigned) |
| **XOR** | R | `0110011` | `100` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0101` (XOR) | 0 | Bitwise Exclusive OR |
| **SRL** | R | `0110011` | `101` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0110` (SRL) | 0 | Shift Right Logical |
| **SRA** | R | `0110011` | `101` | `0100000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0111` (SRA) | 0 | Shift Right Arithmetic |
| **OR** | R | `0110011` | `110` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `1000` (OR) | 0 | Bitwise Logical OR |
| **AND** | R | `0110011` | `111` | `0000000` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `1001` (AND) | 0 | Bitwise Logical AND |
| **ADDI** | I | `0010011` | `000` | - | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `0000` (ADD) | 0 | Add Immediate |
| **SLTI** | I | `0010011` | `010` | - | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `0011` (SLT) | 0 | Set Less Than Imm (Signed) |
| **SLTIU** | I | `0010011` | `011` | - | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `0100` (SLTU) | 0 | Set Less Than Imm (Unsigned) |
| **XORI** | I | `0010011` | `100` | - | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `0101` (XOR) | 0 | Bitwise XOR Immediate |
| **ORI** | I | `0010011` | `110` | - | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `1000` (OR) | 0 | Bitwise OR Immediate |
| **ANDI** | I | `0010011` | `111` | - | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `1001` (AND) | 0 | Bitwise AND Immediate |
| **SLLI** | I | `0010011` | `001` | `0000000` | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `0010` (SLL) | 0 | Shift Left Logical Imm |
| **SRLI** | I | `0010011` | `101` | `0000000` | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `0110` (SRL) | 0 | Shift Right Logical Imm |
| **SRAI** | I | `0010011` | `101` | `0100000` | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `0111` (SRA) | 0 | Shift Right Arithmetic Imm |
| **LB** | I | `0000011` | `000` | - | 1 | 1 | 1 | 0 | 1 | 0 | 0 | `0000` (ADD) | 0 | Load Byte (Sign-Extended) |
| **LH** | I | `0000011` | `001` | - | 1 | 1 | 1 | 0 | 1 | 0 | 0 | `0000` (ADD) | 0 | Load Halfword (Sign-Extended) |
| **LW** | I | `0000011` | `010` | - | 1 | 1 | 1 | 0 | 1 | 0 | 0 | `0000` (ADD) | 0 | Load Word (32-Bit) |
| **LBU** | I | `0000011` | `100` | - | 1 | 1 | 1 | 0 | 1 | 0 | 0 | `0000` (ADD) | 0 | Load Byte Unsigned (Zero-Ext) |
| **LHU** | I | `0000011` | `101` | - | 1 | 1 | 1 | 0 | 1 | 0 | 0 | `0000` (ADD) | 0 | Load Halfword Unsigned (Zero-Ext) |
| **SB** | S | `0100011` | `000` | - | 0 | 1 | 0 | 1 | 0 | 0 | 0 | `0000` (ADD) | 0 | Store Byte (8-Bit) |
| **SH** | S | `0100011` | `001` | - | 0 | 1 | 0 | 1 | 0 | 0 | 0 | `0000` (ADD) | 0 | Store Halfword (16-Bit) |
| **SW** | S | `0100011` | `010` | - | 0 | 1 | 0 | 1 | 0 | 0 | 0 | `0000` (ADD) | 0 | Store Word (32-Bit) |
| **BEQ** | B | `1100011` | `000` | - | 0 | 0 | 0 | 0 | 0 | 1 | 0 | `0001` (SUB) | 0 | Branch if Equal (`rs1 == rs2`) |
| **BNE** | B | `1100011` | `001` | - | 0 | 0 | 0 | 0 | 0 | 1 | 0 | `0001` (SUB) | 0 | Branch if Not Equal (`rs1 != rs2`) |
| **BLT** | B | `1100011` | `100` | - | 0 | 0 | 0 | 0 | 0 | 1 | 0 | `0011` (SLT) | 0 | Branch if Less Than (Signed) |
| **BGE** | B | `1100011` | `101` | - | 0 | 0 | 0 | 0 | 0 | 1 | 0 | `0011` (SLT) | 0 | Branch if Greater/Equal (Signed) |
| **BLTU** | B | `1100011` | `110` | - | 0 | 0 | 0 | 0 | 0 | 1 | 0 | `0100` (SLTU) | 0 | Branch if Less Than (Unsigned) |
| **BGEU** | B | `1100011` | `111` | - | 0 | 0 | 0 | 0 | 0 | 1 | 0 | `0100` (SLTU) | 0 | Branch if Greater/Equal (Unsigned) |
| **JAL** | J | `1101111` | - | - | 1 | 0 | 0 | 0 | 0 | 0 | 1 | `0000` (PC+4) | 0 | Jump and Link (`rd = PC+4`) |
| **JALR** | I | `1100111` | `000` | - | 1 | 1 | 0 | 0 | 0 | 0 | 1 | `0000` (ADD) | 0 | Jump and Link Register (`rs1+imm`) |
| **LUI** | U | `0110111` | - | - | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `1100` (PASS) | 0 | Load Upper Immediate (`imm << 12`) |
| **AUIPC** | U | `0010111` | - | - | 1 | 1 | 0 | 0 | 0 | 0 | 0 | `0000` (ADD) | 0 | Add Upper Imm to PC (`PC+imm`) |
| **FENCE** | I | `0001111` | `000` | - | 0 | 0 | 0 | 0 | 0 | 0 | 0 | `0000` (NOP) | 0 | Order Memory Accesses (NOP) |
| **ECALL** | I | `1110011` | `000` | `0000000` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | `0000` (NOP) | 0 | Environment Call (Simulation Halt) |
| **EBREAK**| I | `1110011` | `000` | `0000001` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | `0000` (NOP) | 0 | Environment Breakpoint (Trap) |
| **MUL** | R | `0110011` | `000` | `0000001` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0000` (MUL) | 1 | Multiply Lower 32-bits (Signed) |
| **MULH** | R | `0110011` | `001` | `0000001` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0001` (MULH) | 1 | Multiply Upper 32-bits (Signed x Signed) |
| **MULHSU**| R | `0110011` | `010` | `0000001` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0010` (MULHSU)| 1 | Multiply Upper 32-bits (Signed x Unsigned) |
| **MULHU** | R | `0110011` | `011` | `0000001` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0011` (MULHU) | 1 | Multiply Upper 32-bits (Unsigned x Unsigned) |
| **DIV** | R | `0110011` | `100` | `0000001` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0100` (DIV) | 1 | Signed Integer Division |
| **DIVU** | R | `0110011` | `101` | `0000001` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0101` (DIVU) | 1 | Unsigned Integer Division |
| **REM** | R | `0110011` | `110` | `0000001` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0110` (REM) | 1 | Signed Remainder |
| **REMU** | R | `0110011` | `111` | `0000001` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | `0111` (REMU) | 1 | Unsigned Remainder |

---

## 3. Immediate Field Decoding Schemes

All 32-bit immediate encodings extract bits according to the RISC-V specification and apply sign extension:

- **I-Type**: `imm[11:0] = inst[31:20]`  
  `sign_ext = {{20{inst[31]}}, inst[31:20]}`
- **S-Type**: `imm[11:0] = {inst[31:25], inst[11:7]}`  
  `sign_ext = {{20{inst[31]}}, inst[31:25], inst[11:7]}`
- **B-Type**: `imm[12:1] = {inst[31], inst[7], inst[30:25], inst[11:8]}, imm[0] = 0`  
  `sign_ext = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}`
- **U-Type**: `imm[31:12] = inst[31:12], imm[11:0] = 0`  
  `sign_ext = {inst[31:12], 12'h000}`
- **J-Type**: `imm[20:1] = {inst[31], inst[19:12], inst[20], inst[30:21]}, imm[0] = 0`  
  `sign_ext = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}`
