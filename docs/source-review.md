# Review of the downloaded training folders

Reviewed the six folders under `C:\Users\chenn\Downloads\Verilog_Training` on 2026-11-02. The review informed the topics included in this portfolio. The new RTL and testbenches here were written independently; source repositories are not copied into this project.

| Downloaded folder | Contents seen | Useful learning material | Limits to keep in mind |
|---|---|---|---|
| `4_bit_rcfull_adder_register-main` | 1-bit and 4-bit ripple adder, D flip-flop, registered adder, exhaustive testbench, long README | Clear hierarchy and clocked output exercise; testbench loops over 16 × 16 × 2 input combinations | README makes strong performance/glitch claims that are not established by functional simulation alone. The testbench is simulation evidence, not timing closure or physical verification. |
| `4-bit-ripple-carry-full-adder-main` | Verilog and SystemVerilog ripple adder versions and benches | Good focused example of structural carry propagation and comparing HDL styles | Documentation reports tool results, but those claims should be rerun locally before relying on them. |
| `d_flip_flop-main` | DFF implementations and benches in Verilog and SystemVerilog | Helpful comparison of basic sequential logic and reset styles | Async and sync reset behavior must not be treated as interchangeable; identify reset type in every design/interface. |
| `RISC-V_practice-main` | DFF, registered adders, and a file named as a RISC-V processor | Useful collection of early exercises and a datapath/control example | Processor uses custom 4-bit opcodes and 3-bit register indices, so it is a teaching CPU rather than standard RISC-V. Review its load/store and branch semantics before extending it. |
| `RISC-V_WORKSHOP-main` | Adder, ALU, DFF, elevator and appliance-controller FSM examples | Broad selection of combinational, sequential, and controller topics | A file named `4bit_halfadder` calculates bitwise XOR and AND without carry propagation, not ordinary 4-bit binary addition. Some benches are demonstrations rather than automated self-checking verification. |
| `Verilog_Training-main` | Bitwise half-adder-style block and 4-bit ALU | Useful examples of ALU operation selection, carry/borrow and zero flags | The half-adder module produces per-bit XOR and AND vectors; it does not cascade carry. Bench examples cover selected values, not the full input space. |

## How this project uses the review

The portfolio focuses on four connected skills: a real carry-propagating adder, a registered datapath with an explicitly synchronous reset, an ALU with documented flags, and a Moore-style controller. The terms “half adder,” “ripple-carry adder,” “synchronous reset,” and “RISC-V” are used precisely in the documentation. Testbenches are included so the learner can run and inspect them. No simulation results are represented as already obtained.

## Attribution and ownership

The downloaded folders remain untouched in their original location. This repository contains fresh implementations of common digital-logic exercises, not copied source files. Its MIT license applies to the new files in this repository only and does not relicense the downloaded projects.
