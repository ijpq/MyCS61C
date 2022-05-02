.globl test
.text


test:
    addi sp, sp, -4
    sw ra, 0(sp)
    li a1, 100
    jal ra, print_int
    li a1, 0
    jal ra, fflush
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
