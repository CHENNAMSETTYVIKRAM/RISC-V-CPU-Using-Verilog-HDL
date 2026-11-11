# Program 4: In-place Bubble Sort of 5 numbers in data memory
# Inputs in mem[0..4]: [64, 25, 12, 22, 11]
# Output in mem[0..4]: [11, 12, 22, 25, 64]
addi x1, x0, 5
outer_loop:
addi x1, x1, -1
beq  x1, x0, done
addi x2, x0, 0
inner_loop:
lw   x3, 0(x2)
lw   x4, 4(x2)
blt  x3, x4, no_swap
sw   x4, 0(x2)
sw   x3, 4(x2)
no_swap:
addi x2, x2, 4
slli x5, x1, 2
blt  x2, x5, inner_loop
jal  x0, outer_loop
done:
end:
jal  x0, end
