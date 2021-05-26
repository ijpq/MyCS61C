.import ../../src/utils.s
.import ../../src/classify.s
.import ../../src/argmax.s
.import ../../src/dot.s
.import ../../src/matmul.s
.import ../../src/read_matrix.s
.import ../../src/relu.s
.import ../../src/write_matrix.s

.data

.globl main_test
.text
# main_test function for testing
main_test:

    # call classify function
    jal ra classify

    # exit normally
    jal exit
