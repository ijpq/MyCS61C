.import ../../src/utils.s
.import ../../src/relu.s

.data
m0: .word 
msg0: .asciiz "expected a1 to be 115 not: "

.globl main_test
.text
# main_test function for testing
main_test:
    # Prologue
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)


    # load address to array m0 into a0
    la a0 m0

    # load 0 into a1
    li a1 0

    # call relu function
    jal ra relu

    # save all return values in the save registers
    mv s1 a1


    # check that a1 == 115
    li t0 115
    beq s1 t0 a1_eq_115
    # print error and exit
    la a1, msg0
    jal print_str
    mv a1 s1
    jal print_int
    # Print newline
    li a1 '\n'
    jal ra print_char
    # exit with code 8 to indicate failure
    li a1 8
    jal exit2
    a1_eq_115:


    # exit normally
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8

    jal exit
