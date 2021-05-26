.import ../../src/utils.s
.import ../../src/dot.s

.data
m0: .word 1 2 3 4 5 6 7 8 9
m1: .word 1 2 3 4 5 6 7 8 9
msg0: .asciiz "expected a1 to be 123 not: "

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

    # load address to array m1 into a1
    la a1 m1

    # load 3 into a2
    li a2 3

    # load 0 into a3
    li a3 0

    # load 2 into a4
    li a4 2

    # call dot function
    jal ra dot

    # save all return values in the save registers
    mv s1 a1


    # check that a1 == 123
    li t0 123
    beq s1 t0 a1_eq_123
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
    a1_eq_123:


    # exit normally
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8

    jal exit
