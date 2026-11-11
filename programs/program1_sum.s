# Program 1: Sum of 1 to N (N = 10)
# Final sum stored in x3 (Expected: 55)
addi x2, x0, 10
addi x3, x0, 0
loop:
add  x3, x3, x2
addi x2, x2, -1
bne  x2, x0, loop
end:
jal  x0, end
