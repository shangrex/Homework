.data
str1:     .string "The answer is True."
str2:     .string "The answer is False."

.text
    addi a1, x0, 10           # input n = 10
    andi t0, a1, 1            # t = n&1
loop1:
    beq a1, x0, return_t      # while( n != 0 )
    srai a1, a1, 1            #  n = n >> 1
    andi t1, a1, 1            #  t1 =  (n&1)
    beq t0, t1, return_f      #  if(t == (n&1)) return false
    andi t0, a1, 1            #  t = n & 1
    jal ra, loop1
return_f:
    la a0, str2               #  print False
    jal ra, finish
return_t:
    la a0, str1               #  print True
finish:
    li a7, 4
    ecall
    nop