# Day 4 Activity 4.1: Data Hazard Test Program
# 1. Back-to-back dependent arithmetic instructions (EX-to-EX forwarding)
# 2. Load followed immediately by dependent instruction (Load-Use 1-cycle stall + forwarding)
# Expected results: x1=10, x2=15, x3=25, x4=25, x5=35
addi x1, x0, 10
addi x2, x1, 5
add  x3, x2, x1
sw   x3, 0(x0)
lw   x4, 0(x0)
addi x5, x4, 10
end:
jal  x0, end
