# Program 2: First 10 Fibonacci numbers stored in data memory mem[0..9]
# Expected mem[0..9] = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
addi x1, x0, 0     # Memory pointer (byte address)
addi x2, x0, 0     # Fib(0) = 0
addi x3, x0, 1     # Fib(1) = 1
addi x4, x0, 10    # Total count = 10
addi x6, x0, 1     # Loop bound limit = 1
sw   x2, 0(x1)     # mem[0] = 0
addi x1, x1, 4
loop:
sw   x3, 0(x1)     # mem[i] = current fib
add  x5, x2, x3    # next = a + b
addi x2, x3, 0     # a = b
addi x3, x5, 0     # b = next
addi x1, x1, 4     # advance mem pointer
addi x4, x4, -1    # decrement counter
bne  x4, x6, loop
end:
jal  x0, end
