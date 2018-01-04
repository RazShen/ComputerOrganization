# 207071192 Sapir Kikoz

.data
.section .rodata

.align 8 # Align address to multiple of 8
SWITCH:
	.quad case50
	.quad case51
	.quad case52
	.quad case53
	.quad case54
	.quad default


    # for the switch case
    option_50_output_format:    .string "first pstring length: %d, second pstring length: %d\n"
    option_51_output_format:    .string "old char: %c, new char: %c, first string: %s, second string: %s\n" 
    option_52_output_format:    .string "length: %d, string: %s\n"
    optiom_53_output_format:    .string "length: %d, string: %s\n"
    optiom_54_output_format:    .string "compare result: %d\n"
    invalid_option_output_format:   .string "invalid option!\n"
    
text
.globl run_func
	.type run_func, @function
run_func:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14


    leaq -50(%rdi), %r8
    cmpq $5, %r8
    ja default
    jmp *SWITCH(,%r8,8)
     

    case50:
    ##################################################################################
    # option 50
    #in the switch case put the first byte of r13 to any register -- rbx , and then put the value of it rax
    #the second time we call the pstrlen put again the first byte of r14 to rbx

    leaq (%r13), %rbx                   #r14 is a pointer to where the whole pstring sits in the stack, we move its value to rbx pstlen read 
                                        #from rbx 
    movsbq (%rbx), %rbx                 #because we dont want the whole pstring we want to move only the first byte to rbx
    call pstrlen
    
    movq %rax, %rsi                     #the second argument to printf function
    
    leaq (%r14), %rbx                   #r14 is a pointer to where the whole pstring sits in the stack, we move its value to rbx
    movsbq (%rbx), %rbx                 #because we dont want the whole pstring we want to move only the first byte to rbx
    call pstrlen
    
    movq %rax, %rdx                     #the third argument to printf function
    movq $option_50_output_format, %rdi #the first argument to the printf function
    xorq %rax, %rax
    call printf
    jmp end
    ###########################################################
     
     
     
     
    case51:
    ###########################################################
    #option 51
    #start scaning single chars - first char
    
    pushq %rdx #second s
    pushq %rsi #first s
    movq $char_input_format, %rdi       #move the first parameter to rdi -- the fomat that we want to scan
                                        #because of scanf syntax

    
    movq $0, %rbx
    pushq %rbx                          #we push a number to the stack for allocate 8 bytes
    
 
                                        #a number that we will override****************
    movq %rsp, %rsi                     #-------rsp is the address of the stack pointer , rsi holds the address to wherer to write
                                        #so now, after we passed to rsi the address to the stack - we writing on the stack
                                        #which means that e write on the register that e pushed to the stack!!!!-----------
    xorq %rax, %rax
    call scanf
    
    #start scaning single chars - first char - second char
    movq $char_input_format, %rdi       #move the first parameter to rdi -- the fomat that we want to scan
                                        #because of scanf syntax
    
    movq $0, %rbx
    pushq %rbx                          #we push a number to the stack for allocate 8 bytes
    
 
                                        #a number that we will override****************
    movq %rsp, %rsi                     #-------rsp is the address of the stack pointer , rsi holds the address to wherer to write
                                        #so now, after we passed to rsi the address to the stack - we writing on the stack
                                        #which means that e write on the register that e pushed to the stack!!!!-----------
    xorq %rax, %rax
    call scanf
 
    
    popq %rdx                           #the second char is into rdx
    popq %rsi                           #the first char is into rsi
    popq %rdi                           #first str
    
    movq %rdx, %r12                     #the second char is into r12
    movq %rsi, %r13                     #the first char is into r13
    movq %rdi, %r14                     #the first string is into r14
    
    call replaceChar
    
    popq %rdi
    movq %r13, %rsi
    movq %r12, %rdx
    movq %rax, %r15                      #we save the value from the first call and prepare for the second call
    
    call replaceChar
    
    movq $option_51_output_format, %rdi
    movq %r13, %rsi                      #the first char to the second argument
    movq %r12, %rdx                      #the second char to the third argument
    movq %r15, %rcx                      #the pointer to the first string to the forth argument
    movq %rax, %r8                       #the pinter to the second string to the fifth argument
    incq %rcx
    incq %r8
    xorq %rax, %rax
    call printf
    jmp end
    ###########################################################################################
     
    case52:
    ##########################################################################################
    pushq %rdx #second s
    pushq %rsi #first s
    #scanf the first number - i index
    movq $integer_input_format, %rdi    #move the first parameter to rdi -- the fomat that we want to scan
                                        #because of scanf syntax

    movq $0, %r12
    pushq %r12                          #we push a number to the stack for allocate 8 bytes
                                        #a number that we will override****************
    movq %rsp, %rsi                     #-------rsp is the address of the stack pointer , rsi holds the address to wherer to write
                                        #so now, after we passed to rsi the address to the stack - we writing on the stack
                                        #which means that e write on the register that e pushed to the stack!!!!-----------
    xorq %rax, %rax
    call scanf
    movq $0, %rax                       #return value from scanf
     
     #scanf the second number - j index
    movq $integer_input_format, %rdi    #move the first parameter to rdi -- the fomat that we want to scan
    movq $0, %rbx                       #because of scanf syntax
    pushq %rbx                          #we push a number to the stack for allocate 8 bytes
                                        #a number that we will override****************
    movq %rsp, %rsi                     #rsp is the address of the stack pointer , rsi hold the address to wherer to write
    xorq %rax, %rax
    call scanf
    movq $0, %rax                       #return value from scanf

    
     
     popq %rcx                          #j
     popq %rdx                          #i
     popq %rdi                          #first string  dst
     popq %rsi                          #second string src
     movq %rsi, %r14                    #save the src pointer in a callee save register 
     
     call pstrijcpy
     #only one call then just print, save in calle the pointer to source so we wont lose it when we call
     
     movq $option_52_output_format, %rdi #move the format to the first argument
     movq %rax, %r15                     #move carefully the return value which is the pointer to pstring to arguments
     movzbq (%r15), %rsi
     incb %r15b
     movq %r15, %rdx
     xorq %rax, %rax
     call printf
     
     movq $option_52_output_format, %rdi #move the format to the first argument
     movzbq (%r14), %rsi
     incb %r14b
     movq %r14, %rdx
     xorq %rax, %rax
     call printf 
     
     jmp end
     ##########################################################################################
     
     case53:
     ##########################################################################################
     movq %rdx, %r13                        #second string
     movq %rsi ,%r14                        #first string
     
     
     
     movq %rsi, %rdi                        #we put in rdi the first string to the first argument
     call swapCase
     
     movq $optiom_53_output_format, %rdi
     movq %rax, %rbx                        #the updated pstring is into %rbx
     movzbq (%rbx), %rsi
     incb %bl
     movq %rbx, %rdx
     xorq %rax, %rax
     call printf
     
     
     movq %r13 ,%rdi                         #then we put the second string to the first argument
     call swapCase
     
     movq $optiom_53_output_format, %rdi
     movq %rax, %r12                         #the updated pstring is into %r12
     movzbq (%r12), %rsi
     incb %r12b
     movq %r12, %rdx
     xorq %rax, %rax
     call printf
     
     jmp end
     ##########################################################################################

     case54:
     ##########################################################################################
     pushq %rdx                          #second s
     pushq %rsi                          #first s
     #scanf the first number - i index
     movq $integer_input_format, %rdi    #move the first parameter to rdi -- the fomat that we want to scan
                                         #because of scanf syntax

     movq $0, %r12
     pushq %r12                          #we push a number to the stack for allocate 8 bytes
                                         #a number that we will override****************
     movq %rsp, %rsi                     #-------rsp is the address of the stack pointer , rsi holds the address to wherer to write
                                         #so now, after we passed to rsi the address to the stack - we writing on the stack
                                         #which means that e write on the register that e pushed to the stack!!!!-----------
     xorq %rax, %rax
     call scanf
     movq $0, %rax                       #return value from scanf
     
     #scanf the second number - j index
     movq $integer_input_format, %rdi     #move the first parameter to rdi -- the fomat that we want to scan
     movq $-1, %rbx                       #we initialize to -1 if there is no i and j but only one
                                          #we want to make sure that there were inserted i and j and not only one of them
                                          #so we initialize i to be out of bound if no j was inserted and that is invalid input
     pushq %rbx                           #we push a number to the stack for allocate 8 bytes
                                          #a number that we will override****************
     movq %rsp, %rsi                      #rsp is the address of the stack pointer , rsi hold the address to wherer to write
     xorq %rax, %rax
     call scanf
  
     
     popq %rcx                              #j
     popq %rdx                              #i
     popq %rdi                              #first string  dst
     popq %rsi                              #second string src
     movq %rsi, %r14                        #save the src pointer in a callee save register 
     
     call pstrijcmp
     
     movq $optiom_54_output_format, %rdi
     movq %rax, %rsi
     xorq %rax, %rax
     call printf
     
     
     jmp end
     ##########################################################################################
     
     default:
     movq $invalid_option_output_format, %rdi
     xorq %rax, %rax
     call printf
     
     end:  
     popq %r14
     popq %r13
     popq %r12
     popq %rbx
      
     ret
