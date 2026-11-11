# Day 4 Activity 4.2: Control Hazard Test Program
# 1. Not-taken branch (fallthrough with zero flushes)
# 2. Taken branch (flushes 2 instructions in fetch/decode)
# 3. Unconditional jump (flushes 2 instructions)
# Expected results: x1=1, x2=2, x3=100, x5=200
addi x1, x0, 1
addi x2, x0, 2
beq  x1, x2, fail_branch1
addi x3, x0, 100
beq  x1, x1, taken_branch
addi x3, x3, 999
addi x3, x3, 888
fail_branch1:
addi x3, x3, 777
taken_branch:
jal  x4, jump_target
addi x3, x3, 666
addi x3, x3, 555
jump_target:
addi x5, x0, 200
end:
jal  x0, end
