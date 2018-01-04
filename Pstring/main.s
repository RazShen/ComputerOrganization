# 207071192 Sapir Kikoz

.data
.section .rodata
    integer_input_format:   .string "%d"
    integer_output_format:  .string "your number is: %d\n"
    string_input_format:    .string "%s\0"
    string_output_format:   .string "your string is: %s\n"
    char_input_format:      .string " %c"
    char_output_format:     .string "your char is: %c\n"
    
.text
.global main
    .type main, @function
main:
    #printf
    pushq %rbp                          #we want to save the old frame pointer
    movq %rsp, %rbp                     #create a new frame pointer

    #scanf the first number - the size of the first string
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

    popq %r12
   
    
    subq %r12, %rsp                     #*******now start scan the string: we decreased the the stack by the number to increase the stack 
    subq $2, %rsp                       #we added two bytes above and benitheh
                                        #allocate place on the stack for the string + 2 : pstring holds: lenght -(char) 1 byte
                                        #x- the actual number of bytes fot the string (char)*x bytes , 1 byte for '\0'
    
    movb %r12b, (%rsp)                  #rsp is a pointer so if we write to the value of it we use (%rsp) in "()",
                                        #then, we want to access only the first byte of r12 because we can assume that there is a max
                                        #size for the string 0-255, so the number will be use only int(4 bytes) but when we puts its value to
                                        #the string - this is a char(1 byte) so if int from 0-255 uses 4 bytes so a char value Hex will be
                                        #hold by only one byte (using ascii, for example 255 in int will be a char ascii represented in Hex
                                        #like ff - only one byte is needed). 
    
    leaq 1(%rsp), %rsi                  #we increase +1 the place that rsp points at, so we can write the string on the place on the stack
                                        #that was meant to. we write with rsi 
    
    movq $string_input_format, %rdi
    leaq 1(%rsp), %rsi
    xorq %rax, %rax
    call scanf
    
    leaq (%rsp), %r13                   #we want to save with calle saver the adress of the rsp which contains first pstring

   
    ###########################################################

    #scanf the second number - the size of the second string
    movq $integer_input_format, %rdi    #move the first parameter to rdi -- the fomat that we want to scan
    movq $0, %rbx                       #because of scanf syntax
    pushq %rbx                          #we push a number to the stack for allocate 8 bytes
                                        #a number that we will override****************
    movq %rsp, %rsi                     #rsp is the address of the stack pointer , rsi hold the address to wherer to write
    xorq %rax, %rax
    call scanf
    popq %rbx 

    
    subq %rbx, %rsp                     #*******now start scan the string: we decreased the the stack by the number to increase the stack 
    subq $2, %rsp                       #we added two bytes above and benitheh
                                        #allocate place on the stack for the string + 2 : pstring holds: lenght -(char) 1 byte
                                        #x- the actual number of bytes fot the string (char)*x bytes , 1 byte for '\0'
    
    movb %bl, (%rsp)                    #rsp is a pointer so if we write to the value of it we use (%rsp) in "()",
                                        #then, we want to access only the first byte of r12 because we can assume that there is a max
                                        #size for the string 0-255, so the number will be use only int(4 bytes) but when we puts its value to
                                        #the string - this is a char(1 byte) so if int from 0-255 uses 4 bytes so a char value Hex will be
                                        #hold by only one byte (using ascii, for example 255 in int will be a char ascii represented in Hex
                                        #like ff - only one byte is needed). 
    
    leaq 1(%rsp), %rsi                  #we increase +1 the place that rsp points at, so we can write the string on the place on the stack
                                        #that was meant to. we write with rsi 
    
    movq $string_input_format, %rdi
    leaq 1(%rsp), %rsi
    xorq %rax, %rax
    call scanf
    
    leaq (%rsp), %r14		       #save with callee the address of the pstring
    
    ##################################################################################
    #scan the option number
    
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
    popq %r12

    movq %r12, %rdi                     #hold the number
    movq %r13, %rsi                     #hold the first string
    movq %r14, %rdx                     #hold the second string
    call run_func
    ###########################################################
    
    addq %r12, %rsp                      #we put back into the stack the place we took  
    addq $2, %rsp                        #also two more bytes for i=one pstring
    addq %rbx, %rsp
    addq $2, %rsp
    
    #end main section
    movq %rbp, %rsp	                #restore the old stack pointer - release all used memory.
    popq %rbp                            #restore old frame pointer (the caller function frame)
    ret	                                 #return to caller function (OS)

