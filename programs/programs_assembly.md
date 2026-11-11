# RV32I Benchmark Assembly Programs

This directory contains standard RV32I benchmark assembly programs and compiled hex files for verifying the processor cores (`riscv_core_2stage` and `riscv_core_5stage`).

---

## Program 1: Sum of Integers 1 to N (N = 10)

Calculates $\sum_{i=1}^{10} i = 55$.
Expected final state: `x3 = 55` (`32'h00000037`).

```asm
# Assembly listing (program1_sum.hex)
addi x2, x0, 10       # 0x00: N = 10
addi x3, x0, 0        # 0x04: sum = 0
loop:
add  x3, x3, x2       # 0x08: sum += N
addi x2, x2, -1       # 0x0C: N--
bne  x2, x0, loop     # 0x10: if N != 0, repeat loop
done:
jal  x0, done         # 0x14: infinite loop completion
```

---

## Program 2: First 10 Fibonacci Numbers

Computes and stores the first 10 Fibonacci numbers into word addresses 0 to 9 in Data Memory:
`0, 1, 1, 2, 3, 5, 8, 13, 21, 34`.

```asm
# Assembly listing (program2_fibonacci.hex)
addi x1, x0, 0        # data memory pointer = 0
addi x2, x0, 0        # a = 0
addi x3, x0, 1        # b = 1
addi x4, x0, 10       # count = 10
sw   x2, 0(x1)        # mem[0] = 0
addi x1, x1, 4        # pointer += 4
addi x6, x0, 1        # stop condition
loop:
sw   x3, 0(x1)        # store next Fibonacci number
add  x5, x2, x3       # temp = a + b
addi x2, x3, 0        # a = b
addi x3, x5, 0        # b = temp
addi x1, x1, 4        # next word address
addi x4, x4, -1       # count--
bne  x4, x6, loop     # loop until 10 numbers generated
done:
jal  x0, done
```

---

## Program 3: Maximum Element of an 8-Word Array

Finds the maximum value in an array of 8 integers located in Data Memory at word addresses 0..7:
Input Array: `[12, 45, 7, 89, 23, 56, 3, 34]`.
Expected final state: `x3 = 89` (`32'h00000059`).

```asm
# Assembly listing (program3_max.hex)
addi x1, x0, 0        # base pointer
lw   x3, 0(x1)        # max = mem[0] (12)
addi x1, x1, 4        # pointer += 4
addi x2, x0, 7        # remaining elements = 7
loop:
lw   x4, 0(x1)        # current element
blt  x3, x4, update   # if max < current, jump to update
jal  x0, skip
update:
addi x3, x4, 0        # max = current
skip:
addi x1, x1, 4        # pointer += 4
addi x2, x2, -1       # remaining--
bne  x2, x0, loop
done:
jal  x0, done
```
