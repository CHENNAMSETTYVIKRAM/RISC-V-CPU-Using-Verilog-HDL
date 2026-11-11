# Automated Verification & Test Report

- **Total Test Suites**: 39
- **Suites Passed**: 39
- **Suites Failed**: 0
- **Total Functional Checks**: 719
- **Total Failures**: 0
- **Pass Rate**: 100.0%

## Detailed Test Results

| Test Suite | Category | Checks | Status | Evidence / Details |
|---|---|---|---|---|
| **Ripple-Carry Adder (4-bit)** | Foundation | 512 | `PASSED` | Exhaustive 512 input combinations verified |
| **Registered Adder (4-bit)** | Foundation | 4 | `PASSED` | Synchronous reset and 1-cycle register sampling verified |
| **ALU (4-bit)** | Foundation | 8 | `PASSED` | ADD, SUB with borrow, bitwise logic, and Zero flag verified |
| **Washing Machine Controller FSM** | Foundation | 7 | `PASSED` | All 7 Moore states, actuator safe defaults and sensor handshakes verified |
| **Carry Adder/Subtractor (8-bit)** | Digital Design | 6 | `PASSED` | 8-bit addition, subtraction, carry out, and signed overflow verified |
| **Configurable Counter (8-bit)** | Digital Design | 5 | `PASSED` | Up/Down counting, parallel load, and max_tick/min_tick flags verified |
| **D Flip-Flop (Sync/Async/En)** | Digital Design | 4 | `PASSED` | Synchronous reset, asynchronous reset, and clock enable verified |
| **Edge Detector & Synchronizer** | Digital Design | 4 | `PASSED` | 2-stage input synchronizer, posedge, negedge, and anyedge pulses verified |
| **Button Debouncer Filter** | Digital Design | 3 | `PASSED` | Bounce filtering and stable integration threshold verified |
| **Linear Feedback Shift Register (8-bit)** | Digital Design | 4 | `PASSED` | Fibonacci polynomial x^8+x^6+x^5+x^4+1 verified |
| **Universal Shift Register (8-bit)** | Digital Design | 4 | `PASSED` | Hold, Shift Left, Shift Right, and Parallel Load verified |
| **Priority Encoder (8-to-3)** | Digital Design | 4 | `PASSED` | Priority arbitration (MSB highest priority) and valid output verified |
| **Binary Decoder (3-to-8)** | Digital Design | 9 | `PASSED` | One-hot decoding across all 8 address combinations verified |
| **Synchronous RAM (16x8)** | Memory | 2 | `PASSED` | Synchronous write and synchronous read-out verified |
| **Synchronous ROM (16x8)** | Memory | 3 | `PASSED` | ROM initialization and synchronous lookup verified |
| **Synchronous FIFO (16x8)** | Memory | 6 | `PASSED` | FIFO circular queue, full/empty flags, and overflow protection verified |
| **Hardware Watchdog Timer** | Memory | 3 | `PASSED` | Kick reload, timeout countdown, and 1-cycle recovery reset pulse verified |
| **Round-Robin Arbiter (4-Requester)** | Memory | 3 | `PASSED` | Fair round-robin rotation and active-grant persistence verified |
| **4-Floor Automatic Elevator FSM** | FSM | 4 | `PASSED` | Floor request servicing, up/down direction control, and door dwell verified |
| **ATM Controller FSM** | FSM | 4 | `PASSED` | PIN authentication, transaction execution, balance tracking, and security lockout verified |
| **Pedestrian Traffic Light FSM** | FSM | 3 | `PASSED` | Vehicle signal sequencing, pedestrian request latching, and safety interlock verified |
| **Multi-Coin Vending Machine FSM** | FSM | 3 | `PASSED` | Item dispense, change return, and cancellation refund verified |
| **Sequence Detectors (Mealy & Moore)** | FSM | 4 | `PASSED` | Mealy prompt detection and Moore state detection with overlapping sequence verified |
| **RV32I ALU (32-bit)** | RISC-V | 10 | `PASSED` | ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND, and condition flags verified |
| **Barrel Shifter (32-bit)** | RISC-V | 3 | `PASSED` | SLL, SRL, and SRA operations verified |
| **Register File (32x32)** | RISC-V | 4 | `PASSED` | Dual-read, single-write, internal WB bypass, and x0=0 invariant verified |
| **Immediate Generator** | RISC-V | 5 | `PASSED` | I-type, S-type, B-type, U-type, and J-type immediate sign extensions verified |
| **RISC-V 2-Stage CPU Execution** | RISC-V | 2 | `PASSED` | 2-stage pipeline instruction sequencing, ALU math, SW, and LW verified |
| **RV32I Full Instruction Coverage Matrix** | RISC-V Deep Validation | 37 | `PASSED` | Full RV32I Matrix: All 37 base integer instructions verified with 0 errors |
| **RV32M Extension Execution & Math** | RISC-V Deep Validation | 10 | `PASSED` | RV32M Extension: 8 multiply/divide instructions with div-0 and overflow verified (0 errors) |
| **Advanced Pipeline Hazards & Forwarding** | RISC-V Deep Validation | 8 | `PASSED` | Pipeline Hazards & Forwarding: 8 hazard patterns verified with 0 errors |
| **Assembly Program 1: Sum 1..10** | Benchmarks | 1 | `PASSED` | Program 1 (Sum of 1..10): Final x3 = 55 (Expected: 55) |
| **Assembly Program 2: Fibonacci 10 Words** | Benchmarks | 10 | `PASSED` | Program 2 (Fibonacci): mem[0..9] = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34] (Expected: [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]) |
| **Assembly Program 3: Array Maximum** | Benchmarks | 1 | `PASSED` | Program 3 (Array Max): Final x3 = 89 (Expected: 89) |
| **Assembly Program 4: Bubble Sort (8 Words)** | Benchmarks | 8 | `PASSED` | Program 4 (Bubble Sort 8 Words): mem[0..7] = [4, 11, 12, 22, 25, 34, 64, 90] (Expected: [4, 11, 12, 22, 25, 34, 64, 90]) |
| **Assembly Program 5: Euclid GCD** | Benchmarks | 1 | `PASSED` | Program 5 (Euclid GCD): Final x3 = 6 (Expected: 6) |
| **Assembly Program 6: Shift-Add Multiply** | Benchmarks | 1 | `PASSED` | Program 6 (Shift-Add Mul): Final x3 = 143 (Expected: 143) |
| **Data Hazard Handling (Activity 4.1)** | Pipeline Hazards | 5 | `PASSED` | Data Hazard Program (Activity 4.1): x1=10, x2=15, x3=25, x4=25, x5=35 (Expected: 10,15,25,25,35) |
| **Control Hazard Handling (Activity 4.2)** | Pipeline Hazards | 4 | `PASSED` | Control Hazard Program (Activity 4.2): x1=1, x2=2, x3=100, x5=200 (Expected: 1,2,100,200) |
