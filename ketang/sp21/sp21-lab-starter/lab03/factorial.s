.globl factorial

.data
n: .word 7

.text
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    # YOUR CODE HERE
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 8(sp)
    sw s1, 16(sp)
    mv s0, a0 # save a
    addi t0, x0, 1
    beq s0, t0, end
    addi a0, a0, -1 # call f(a-1)
    jal ra, factorial
    mv s1, a0 # save callee return val
    mul t1, s0, s1
    mv a0, t1
    lw ra, 0(sp)
    lw s0, 8(sp)
    lw s1, 16(sp)
    addi sp, sp, 24
    ret
end:
    add a0, x0, t0
    ret

    

