	;nhow741
	;this program shifts a number 11 places to the left then ANDs the answer with b0111100000000000

			.orig x3000
			LD R0, number				
			AND R1, R1, #0

	;loop will add number stored in R0 to itself, 11 times
	;R1 will track number of times added, when 11 will go to print stage
	loop		ADD R1, R1, #1
			ADD R0, R0, R0 
			ADD R3, R1, #-11
			BRz print
			BRnzp loop	
			
	;R0 used for working
	;R1 stores the binary number which ANDS with number
	;R2 will hold the ANDED result
	;R3 stores the count of bits printed and mask index to be ANDED
	;R4 holds adress of bonary mask
	print		LD R1, binaryAnd
			AND R2, R0, R1
			AND R3, R3, #0

	maskCheck	LEA R4, B_MASK
			ADD R0, R3, #-16
			BRz finish			;if count is 16 then no more bits required to print
			ADD R4, R4, R3			;choose R3 index of mask
			LDR R0, R4, #0			;load binary number from mask 
			ADD R3, R3, #1			;increment count by one

			AND R0, R0, R2			;ANDS original number with mask binary number
			BRnp printOne
			Brz printZero


	printOne 	LEA R0, one
			puts
			BRnzp maskCheck	

	printZero 	LEA R0, zero
			puts
			BRnzp maskCheck	


	finish halt
			
			


binaryAnd 	.FILL b0111100000000000
number		.FILL b0000000000011011

B_MASK  	.FILL   b1000000000000000	;binary mask
        	.FILL   b0100000000000000
        	.FILL   b0010000000000000
        	.FILL   b0001000000000000
        	.FILL   b0000100000000000
        	.FILL   b0000010000000000
        	.FILL   b0000001000000000
        	.FILL   b0000000100000000
        	.FILL   b0000000010000000
        	.FILL   b0000000001000000
        	.FILL   b0000000000100000
        	.FILL   b0000000000010000
        	.FILL   b0000000000001000
        	.FILL   b0000000000000100
        	.FILL   b0000000000000010
        	.FILL   b0000000000000001

one	.stringz "1 "
zero 	.stringz "0 "

	.end
