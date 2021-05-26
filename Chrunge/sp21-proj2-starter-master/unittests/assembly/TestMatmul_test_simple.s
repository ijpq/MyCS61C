.import ../../src/utils.s
.import ../../src/matmul.s
.import ../../src/dot.s

.data
m0: .word 1 2 3 4 5 6 7 8 9
m1: .word 1 2 3 4 5 6 7 8 9
m2: .word 0 0 0 0 0 0 0 0 0
m3: .word 30 36 42 66 81 96 102 126 150
msg0: .asciiz "expected m2 to be:\n30 36 42 66 81 96 102 126 150\nInstead it is:\n"

.globl main_test
.text
# main_test function for testing
main_test:

    # load address to array m0 into a0
    la a0 m0

    # load 3 into a1
    li a1 3

    # load 3 into a2
    li a2 3

    # load address to array m1 into a3
    la a3 m1

    # load 3 into a4
    li a4 3

    # load 3 into a5
    li a5 3

    # load address to array m2 into a6
    la a6 m2

    # call matmul function
    jal ra matmul

    ##################################
    # check that m2 == [30, 36, 42, 66, 81, 96, 102, 126, 150]
    ##################################
    # a0: exit code
    li a0, 2
    # a1: expected data
    la a1, m3
    # a2: actual data
    la a2, m2
    # a3: length
    li a3, 9
    # a4: error message
    la a4, msg0
    jal compare_int_array

    # exit normally
    jal exit
