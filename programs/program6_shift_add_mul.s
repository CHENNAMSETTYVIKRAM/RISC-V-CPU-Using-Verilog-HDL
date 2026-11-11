# Program 6: Software Shift-and-Add Multiplication (without hardware MUL)
# Multiplies multiplicand x1 = 13 by multiplier x2 = 11 -> product x3 = 143
addi x1, x0, 13
addi x2, x0, 11
addi x3, x0, 0
mul_loop:
beq  x2, x0, mul_done
andi x4, x2, 1
beq  x4, x0, shift_step
add  x3, x3, x1
shift_step:
slli x1, x1, 1
srli x2, x2, 1
jal  x0, mul_loop
mul_done:
end:
jal  x0, end
