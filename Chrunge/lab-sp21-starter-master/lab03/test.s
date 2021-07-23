.globl func
main:
    jal func
    li a0, 10 # Code for exit ecall
    ecall

func:
    # Paste the example definition of func
    li s0, 100 # === Error reported here ===
    li s1, 128 # === Error reported here ===
    ret