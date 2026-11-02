# Verilog Training: Digital Design & Simulation

This repository contains Verilog HDL implementations and testbenches for foundational digital logic blocks, focusing on arithmetic and logical processing units. Each module includes synthesizable RTL code along with self-checking testbenches for functional verification.

---

## Repository Structure

```text
Verilog_Training/
|-- .gitignore
|-- README.md
|-- 4bit_half_adder/
|   |-- half_adder4.v           # 4-bit parallel half adder design module
|   \-- half_adder4_tb.v        # Testbench with stimulus and $monitor logging
\-- project/
    \-- alu4bit/
        |-- alu4.v              # 4-bit Arithmetic Logic Unit with status flags
        \-- alu4_tb.v           # Comprehensive testbench covering all opcodes
```

---

## Modules Overview

### 1. 4-Bit Parallel Half Adder (`half_adder4`)

* **Path:** `4bit_half_adder/half_adder4.v`
* **Modeling Style:** Dataflow (`assign`)
* **Description:** Implements a bitwise 4-bit half adder computing sum and carry independently for each corresponding bit position across two 4-bit input vectors.

#### Logic Equations:
- **Sum:** `Sum[i] = A[i] ^ B[i]`
- **Carry:** `Carry[i] = A[i] & B[i]`

#### Port Specification:
| Signal | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `A` | Input | `[3:0]` | 4-bit Operand A |
| `B` | Input | `[3:0]` | 4-bit Operand B |
| `Sum` | Output | `[3:0]` | 4-bit bitwise sum output |
| `Carry` | Output | `[3:0]` | 4-bit bitwise carry output |

#### Testbench Scenarios (`half_adder4_tb.v`):
Simulates four representative input vectors across time increments of 20 ns:
1. `A = 0101`, `B = 0011` -> `Sum = 0110`, `Carry = 0001`
2. `A = 1010`, `B = 0101` -> `Sum = 1111`, `Carry = 0000`
3. `A = 1111`, `B = 1111` -> `Sum = 0000`, `Carry = 1111`
4. `A = 0000`, `B = 0000` -> `Sum = 0000`, `Carry = 0000`

---

### 2. 4-Bit Arithmetic Logic Unit (`alu4`)

* **Path:** `project/alu4bit/alu4.v`
* **Modeling Style:** Behavioral (`always @(*)`, combinational `case` statement)
* **Description:** A versatile 4-bit ALU performing 5 distinct arithmetic and logic operations based on a 3-bit operation code (`opcode`), generating the computation result along with carry/borrow and zero status flags.

#### Port Specification:
| Signal | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `A` | Input | `[3:0]` | 4-bit input operand A |
| `B` | Input | `[3:0]` | 4-bit input operand B |
| `opcode` | Input | `[2:0]` | 3-bit operation selection code |
| `result` | Output | `[3:0]` | 4-bit computation result |
| `carry_borrow` | Output | `1` | Carry-out flag (addition) or borrow flag (subtraction) |
| `zero` | Output | `1` | Asserted (`1'b1`) when `result == 4'b0000` |

#### Instruction / Opcode Set:
| `opcode` | Operation | Description | Flag Handling |
| :---: | :---: | :--- | :--- |
| `3'b000` | **ADD** | `A + B` | `carry_borrow` set to bit 4 of 5-bit temp sum (`temp[4]`) |
| `3'b001` | **SUBTRACT** | `A - B` | `carry_borrow` set when borrow occurs (`A < B`) |
| `3'b010` | **AND** | `A & B` | Bitwise AND; `carry_borrow = 0` |
| `3'b011` | **OR** | `A \| B` | Bitwise OR; `carry_borrow = 0` |
| `3'b100` | **XOR** | `A ^ B` | Bitwise XOR; `carry_borrow = 0` |
| *default* | **DEFAULT** | `4'b0000` | Default reset; `carry_borrow = 0` |

* **Zero Flag Logic:** Evaluated across all operations. Whenever `result == 4'b0000`, `zero` is driven to `1'b1`; otherwise `1'b0`.

#### Testbench Verification (`alu4_tb.v`):
Verifies arithmetic overflow/carry, subtraction with borrow, logical masking, and zero flag assertion:
- **ADD:** `5 + 3 = 8` (`result = 1000`, `carry = 0`, `zero = 0`)
- **ADD (Overflow/Carry):** `15 + 1 = 0` (`result = 0000`, `carry = 1`, `zero = 1`)
- **SUB:** `5 - 3 = 2` (`result = 0010`, `borrow = 0`, `zero = 0`)
- **SUB (Borrow):** `3 - 5 = 14` (`result = 1110`, `borrow = 1`, `zero = 0`)
- **AND:** `5 & 3 = 1` (`result = 0001`, `zero = 0`)
- **OR:** `5 | 3 = 7` (`result = 0111`, `zero = 0`)
- **XOR:** `5 ^ 3 = 6` (`result = 0110`, `zero = 0`)
- **Zero Flag Check:** `5 - 5 = 0` (`result = 0000`, `borrow = 0`, `zero = 1`)

---

## How to Simulate

### Using ModelSim / QuestaSim:
```bash
# Create working library
vlib work

# Compile design and testbench (e.g. 4-bit ALU)
vlog project/alu4bit/alu4.v project/alu4bit/alu4_tb.v

# Run command-line simulation
vsim -c alu4_tb -do "run -all; quit"
```

### Using Icarus Verilog & GTKWave:
```bash
# Compile and run 4-bit half adder
iverilog -o half_adder4_sim 4bit_half_adder/half_adder4.v 4bit_half_adder/half_adder4_tb.v
vvp half_adder4_sim

# Compile and run 4-bit ALU
iverilog -o alu4_sim project/alu4bit/alu4.v project/alu4bit/alu4_tb.v
vvp alu4_sim
```

### Using EDA Playground:
1. Copy the design file (`.v`) to the **Design** pane.
2. Copy the testbench file (`_tb.v`) to the **Testbench** pane.
3. Select your preferred simulator (e.g., Icarus Verilog or Aldec Riviera Pro) and click **Run**.