# Program 3: Maximum value in an array of 8 words in data memory
# Inputs: mem[0..7] = [12, 45, 7, 89, 23, 56, 3, 34]
# Output: x3 = 89
addi x1, x0, 0     # Pointer
lw   x3, 0(x1)     # max = mem[0]
addi x1, x1, 4
addi x2, x0, 7     # count = 7
loop:
lw   x4, 0(x1)     # current = mem[ptr]
blt  x4, x3, skip
addi x3, x4, 0     # max = current
skip:
addi x1, x1, 4
addi x2, x2, -1
bne  x2, x0, loop
end:
jal  x0, end
