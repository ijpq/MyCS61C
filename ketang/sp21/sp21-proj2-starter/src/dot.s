.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 123.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 124.
# =======================================================
dot:

    # Prologue
    # x31 dot product of v0 and v1
    # SETTING EXCEPTIONS THRESHOULD VAL TO X5
    add x5, x0, x0
    addi x5, x5, 1

    # EXCEPTIONS CHECKING
    blt a2, x5, exce_123
    blt a3, x5, exce_124
    blt a4, x5, exce_124

    add x31, x0, x0
    add x6, x0, x0  #iteration i
    add x7, x0, x0
    add x5, x0, x0
    addi x7, x0, 4  # stride v0
    addi x5, x0, 4  # stride v1
    add x30, x0, x0
    mul x7, x7, a3
    mul x5, x5, a4
    
loop_start:

    beq x6, a2, loop_end
    lw x28, 0(a0)
    lw x29, 0(a1)
    mul x30, x28, x29
    add x31, x31, x30
    #in this impl, we write hard code of stride to 1.
    add a0, a0, x7
    add a1, a1, x5
    addi x6, x6, 1
    j loop_start

loop_end:
    # Epilogue
    add a0, x31, x0
    ret

exce_123:
    li a1, 123
    li a0, 17
    ecall
    ret

exce_124:
    li a1, 124
    li a0, 17
    ecall
    ret
    
