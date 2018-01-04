# 207071192 Sapir Kikoz

.data
.section .rodata

	invalid_input_output_format:    .string "invalid input!\n"

.text
.globl pstrlen
	.type pstrlen, @function
pstrlen:
        pushq %rbp                              #we save the old frame pointer
        movq %rsp, %rbp                         #we move the stack pointer to the base pointer in order to start new frame
        xorq %rax, %rax                         #zero rax
        movq %rbx, %rax                         #from every function the return value is suppose to go to rax
        movq %rbp, %rsp
        popq %rbp
        ret

.globl replaceChar
	.type replaceChar, @function
replaceChar: 
    # 2nd char is in rdx
    # 1st char is in rsi
    # the pstring pointer is in rdi
    movq %rdx, %r8                                  #get the new char - the second char
    movq %rsi, %r11                                 #get the old char - the first char
    movq %rdi, %rsi                                 #get pstr from the stack
    movq %rsi, %r9                                  #save value in order to restor, rsi points at the lenght
    movq (%r9), %rax                                #the lenght of the string to r10
    xorq %rcx, %rcx
    movb %al, %cl
    movq %rcx, %r10
    incq %r9                                        #increment the pointer to where the string begins
    
    xorq %rcx, %rcx                                 #rcx=0
    cmp %rcx, %r10
    ja replaceCharLoop                              #r10 is bigger
    jmp replaceCharEnd
    replaceCharLoop:
    
    xorq %rdx, %rdx                                 # rdx = 0
    xorq %rax, %rax
    movb (%r9), %dl                                 # dl = pstr[i]
    movq %r11, %rax
    cmpb %dl, %al
    
    je replaceChar_if
    jmp replaceChar_endif
    replaceChar_if:
    movq %r8, %rax
    xorq %rdx, %rdx
    movb %al, %dl
    movb %dl, (%r9)
    replaceChar_endif:
    incq %r9                                        #the index of the string
    incq %rcx                                       #the counter of the loop
    cmp %rcx, %r10
    ja replaceCharLoop                              #r10 is bigger
    
    replaceCharEnd:
    movq %rsi, %rax                                 #return value is the poiner to the string
    ret
    
.globl pstrijcpy
	.type pstrijcpy, @function
pstrijcpy:
    #rdi - first string, dst
    #rsi - second string, src
    #rdx - i
    #rcx -j
    
    movb %dl, %al #get i
    movb %cl, %ah #get j
    movq %rsi, %rsi #get second string, src
    movq %rdi, %rdi #get first string, dst
    movq %rdi, %r13
    
    #check that i and j are not out of bound
    cmpb %ah, (%rsi)    #if(j>pstr2.length)
    jb pstrijcpy_if
    cmpb %ah, (%rdi)    #if(j>pstr1.length)
    jb pstrijcpy_if
    cmpb %al, (%rsi)    #if(i>pstr2.length)
    jb pstrijcpy_if
    cmpb %al, (%rdi)    #if(i>pstr1.length)
    jb pstrijcpy_if
    jmp pstrijcpy_endif #else jmp to the end
    
    #if i or j are out of bound we print error message
    pstrijcpy_if:

    movq $invalid_input_output_format, %rdi
    xorq %rax, %rax
    call printf
    jmp pstrijcpy_end 			#jmp to the end of the function
        
    pstrijcpy_endif:
    pstrijcpy_loop: 			#for(,i <= j, i++)
    cmpb %al, %ah
    jb pstrijcpy_end			# if(i > j) jmp to the end
    
    movq $0, %rbx
    movb %al, %bl                        #save i in rbx
    leaq 1(%rsi, %rbx, 1), %rcx          #pstr2[i]
    leaq 1(%rdi, %rbx, 1), %rdx          #pstr1[i]
    
    movq $0, %rbx
    movb (%rcx), %bl 			#pstr1[i] = pstr2[i]
    movb %bl, (%rdx) 
        
    incb %al 					#i++
    jmp pstrijcpy_loop			#continue the loop
    pstrijcpy_end:
    movq %r13, %rax 			#return pstr1
    ret

.globl swapCase
	.type swapCase, @function
swapCase:
    #the string is in rdi
        
    movq %rdi, %rax #get the pstring from rdi
    movzbq (%rax), %rcx #get the lenght of the string
    xorq %rdx, %rdx #i = rdx = 0
    
    swapCase_loop: 	#for(i = 0, i < length, i++)
    cmpb %dl, %cl        #if(i >= length) jmp to the end
    jle swapCase_end
    leaq 1(%rax,%rdx,1), %rbx 	         #str[i], we work on rbx
    cmpb $65, (%rbx) 			#if(str[i] < 65)
    jb swapCase_notCapital
    cmpb $90, (%rbx) 			#if(str[i] > 90)
    ja swapCase_notCapital
    addb $32, (%rbx) 			#make the letter small
    jmp swapCase_notSmall 		
    
    #else
    swapCase_notCapital:
    cmpb $97, (%rbx) 			#if(str[i] < 97)
    jb swapCase_notSmall
    cmpb $122, (%rbx) 			#if(str[i] > 122)
    ja swapCase_notSmall
    subb $32, (%rbx) 			#make the letter capital
    swapCase_notSmall:
    incq %rdx 				#i++ // change to incb
    jmp swapCase_loop 			#jmp to the begining of the loop
    
    swapCase_end:
    #we dont need to move anything to rax because it points on the pstring and we did'nt change it 
    ret

.globl pstrijcmp
	.type pstrijcmp, @function
pstrijcmp:
    #rdi - first string
    #rsi - second string
    #rdx - i
    #rcx -j
    
    movb %dl, %al                       #get i
    movb %cl, %ah                       #get j
    movq %rsi, %rsi                     #get second string
    movq %rdi, %rdi                     #get first string
    
    #now we check if i and j are in bound
    cmpb %ah, (%rsi) 			#if(j>str2.length)
    jb pstrijcmp_if
    cmpb %ah, (%rdi) 			#if(j>str1.length)
    jb pstrijcmp_if
    cmpb %al, (%rsi) 			#if(i>str2.length)
    jb pstrijcmp_if
    cmpb %al, (%rdi) 			#if(i>str1.length)
    jb pstrijcmp_if
    jmp pstrijcmp_endif			#else jmp to the end

    pstrijcmp_if:
    movq $invalid_input_output_format, %rdi
    xorq %rax, %rax
    call printf
    jmp pstrijcmp_error			#jmp to return -2

    pstrijcmp_endif:
    pstrijcmp_loop:                       #for(,i <= j, i++)
    cmpb %al, %ah 			#if(i > j) jmp to the end
    jb pstrijcmp_endloop
    
    xorq %rbx, %rbx 			#rbx = 0
    movb %al, %bl 			#bl = i
    leaq 1(%rdi,%rbx,1), %rcx       	#str1[i]
    leaq 1(%rsi,%rbx,1), %rdx 	        #str2[i]
    
    xorq %rbx, %rbx 			#rbx = 0
    movb (%rcx), %bl 			#bl = str1[i]
    movb (%rdx), %bh 			#bh = str2[i]
    cmpb %bl, %bh
    
    jb pstrijcmp_bigger  		#if(str1[i] > str2[i])
    ja pstrijcmp_smaller             	#if(str1[i] < str2[i])

    incb %al 				#i++
    jmp pstrijcmp_loop 			#continue the loop

    pstrijcmp_endloop: 			#at this point we assume the strings are equal
    xorq %rax, %rax 			#return 0
    jmp pstrijcmp_exit
    
    pstrijcmp_error: 		         #if i or j are out if bounds
    movq $-2, %rax 			 #return -2
    jmp pstrijcmp_exit
    
    pstrijcmp_bigger: 			#if pstr1 is bigger
    movq $1, %rax 			#return 1
    jmp pstrijcmp_exit
    
    pstrijcmp_smaller: 			#if pstr2 is smaller
    movq $-1, %rax			#return -1
    jmp pstrijcmp_exit
    
    pstrijcmp_exit:
    ret
