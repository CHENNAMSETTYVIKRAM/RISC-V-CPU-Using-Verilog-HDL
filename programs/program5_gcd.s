# Program 5: Greatest Common Divisor (GCD) using repeated subtraction
# Input: x1 = 48, x2 = 18
# Output: x3 = GCD(48, 18) = 6
addi x1, x0, 48
addi x2, x0, 18
gcd_loop:
beq  x1, x2, gcd_done
blt  x1, x2, sub_b
sub  x1, x1, x2
jal  x0, gcd_loop
sub_b:
sub  x2, x2, x1
jal  x0, gcd_loop
gcd_done:
addi x3, x1, 0
end:
jal  x0, end
