.import ../../src/main.s

.data

.globl main_test
.text
# main_test function for testing
main_test:

    # call main function
    jal ra main

    # exit normally
    jal exit
