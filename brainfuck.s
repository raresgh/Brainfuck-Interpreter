.bss
buffer: .skip 30000		#
copy_rdi: .skip 8		#registers have 8 bytes
copy_rsi: .skip 8
output_char: .skip 1
counter: .skip 8

.global brainfuck

.text

format_str: .asciz "We should be executing the following code:\n%s"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	movq $buffer, %rsi
	movq %rdi, copy_rdi

	while:
		movzbq (%rdi), %rax
		testq %rax, %rax		#testing if we reached the end
		je end				#if it is  0 jump to end
		
		#-------- CHECK CASES FOR ALL 8 INSTRUCIONS--------
		cmpb $'<', %al
		je move_left

		cmpb $'>', %al
		je move_right

		cmpb $'+', %al
		je increment

		cmpb $'-', %al
		je decrement

		cmpb $'.', %al
		je output

		cmpb $',', %al
		je input

		cmpb $'[', %al
		je loop_start

		cmpb $']', %al
		je loop_end

	next:
		incq %rdi
		jmp while	

move_left:
	decq %rsi			#decrement the data pointer
	jmp next

move_right:
	incq %rsi			#increment the data pointer
	jmp next

increment:
	incb (%rsi)			#increment the byte at the data pointer
	jmp next

decrement:
	decb (%rsi)			#decrement the byte at the data pointer
	jmp next

output:
	movq %rsi, copy_rsi	#make copies of registers because we will lose them
	movq %rdi, copy_rdi

	movb (%rsi), %cl
	movb %cl, output_char

	movq $1 , %rax 				# system call 1 is sys write
	movq $1 , %rdi 				#first argument is where to write ; stdout is 1
	movq $output_char , %rsi 	#next argument : what to write
	movq $1 , %rdx 				#last argument : how many bytes to write
	syscall

	movq copy_rdi, %rdi	#store the copies back to the registers after we are done
	movq copy_rsi, %rsi

	jmp next

input:
	movq %rsi, copy_rsi	#make copies of registers because we will lose them
	movq %rdi, copy_rdi

	movq $0, %rax		#System call  number fo input
	movq $1, %rdx		#Last argument(Size of input - 1 byte)
	movq $0, %rdi		#First argument(where to write)

	subq $16, %rsp		#Allocate space on the stack and keep it aligned
	leaq (%rsp), %rsi	#where syscall stores the value

	syscall

	movq copy_rdi, %rdi	#store the copies back to the registers after we are done
	movq copy_rsi, %rsi

	movb (%rsp), %cl	#move rest of chars temporarily in cl
	movb %cl, (%rsi)	#then store it in the buffer

	add $16, %rsp		#clear memory on the stack

	jmp next

loop_start:

	pushq	%rdi			#push the address of the [ instruction to know where to come back when we start the loops
	pushq	%rdi			#push it a second time to keep the stack aligned

	movzbq (%rsi), %rcx		#move data pointer of the buffer
	testb %cl, %cl			#test if data pointer is 0
	jne	next				#if it is not 0 then enter the loop

	popq	%rdi			#pop the addresses of the stack
	popq	%rdi

	mov $0, counter				#initalize coutner for the loop

	search_closed:
		movb (%rdi), %cl		#move the the instruction to cl to compare it
		cmpb $'[', %cl			
		je increment_counter	#if we have an open loop we increment the counter

		cmpb $']', %cl
		je decrement_counter	#if we have a closed loop we decrement the counter

		next_search:
			cmpb $0, counter	#if counter is 0
			je next				#go to next instruction
			incq %rdi			#else it means we still are in nested loops
			jmp search_closed	#and we have to still search for closed brackets

	increment_counter:
		incq counter			#increase the actual counter
		jmp next_search			#jump to next search

	decrement_counter:
		decq counter			#decrease the actual counter
		jmp next_search			#jump to next search

loop_end:
	movb (%rsi), %cl			#move the data pointer of the buffer to compare it
	testb %cl, %cl				#test whether data pointer is 0 or not
	jne go_back					#if it is not do the loop again

	pop %rcx					#if the data pointer is 0 we pop the addresses of the open brackets
	pop %rcx

	jmp next					#and jump to the next instruction after them

	go_back:
		pop %rdi				#pop the address value(these 2 are just to get the address we have to return to)
		push %rdi				#push the aaddress back on the stack
		jmp next				#jmp next but the instruction register is going to point back to the start of the loop

end:

	#epilogue
	movq %rbp, %rsp
	popq %rbp
	ret
