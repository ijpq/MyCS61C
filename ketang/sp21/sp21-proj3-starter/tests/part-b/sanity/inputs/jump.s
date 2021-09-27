jal ra label        # 0
addi s0 x0 -1       # 1
jal x0 end          # 2
label: jalr x0 ra 0 # 3
end: addi a0 x0 -1  # 4

# Order: 0, 3, 1, 2, 4
