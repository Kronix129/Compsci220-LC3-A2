	;nhow741
	;this program will take user input between -511 and +511
	;it will then convert this string into a integer
	;finally it will print the integer as a 16-bit binary number, via the use of a binary mask
			
			
			.orig x3000
	beginning	LEA R0, enter
			puts
			LEA R1, number
			

	;this takes user input and stores in location under number
	char		getc
			out
			add R2, R0, #-10	;if new line character/enter is entered then input is done
			BRZ stop
			str R0, R1, #0
			add R1, R1, #1
			BRnzp char

	
	;after input has been entered, an end of input signal is inserted '!'
	;this will stop overlapping/reset input each time
	;takes the first character of number, checks if it is a + sign
	;R2 stores ascii of plus, and turns it into it's negative value
	;R3 loads '!', which is then stored to end of the user input
	stop		LD R3, end_signal
			str R3, R1, #0
			
			LEA R1, number
			LDR R2, R1, #0
			LD R3, PLUS		;loads ascii for plus sign 
			ADD R0, R2, R3		;
			BRz validSign		;if CC = 0 then first character was plus sign 
				 
		
	;first character still might be a '-' sign, this part checks for that
			LEA R1, number
			LDR R2, R1, #0
			LD R3, NEGATIVE		;loads ascii for negative sign
			
			ADD R0, R2, R3
			BRz validSign

	;if first character is not '+' or '-' then it is invalid
	invalidPrint	LEA R0, invalid
			puts
			BRnzp beginning

			
	validSign	LD R3, NEGATIVE
			ADD R0, R2, R3
			BRz negTrack			;method to check if operator is negative
			ADD R1, R1 #1			;increments address past operator sign
			LD R2, ASCII			;loads negative ASCII offset
			AND R0, R0, #0			;clears R0
			BRnzp converter
					
		
	
	
	;adds the value 1 to register 7 to signal number is negative
	;register 7 will be referenced again later to check it number was negative	
	negTrack	AND R7, R7, #0
			ADD R7, R7, #1
			ADD R1, R1, #1
			LD R2, ASCII
			AND R0, R0, #0
			
	     		

	;this part will convert string of digits into an integer
	;R0 will store the integer
	;R1 will point to characters in the buffer
	;R2 will hold the negative ascii offset 
	;R3, R4, R5 used for work space

			
			
	converter	LDR R3, R1, #0			;loads character into R3
			LD R4, end_minus		;loads negative of end signal
			ADD R4, R3, R4	
			BRz completed			;if zero, then end signal has been reached
			
			ADD R3, R3, R2			;converts into int value

			;multiple R0 by 10
			ADD R4, R0, R0			;R4 = 2 x R0
			ADD R5, R4, R4			;R5 = 4 X R0
			ADD R5, R5, R5			;R5 = 8 X R0
			ADD R0, R4, R5			;R0 = 10 X R0
			
			;add the new digit 
			ADD R0, R0, R3

			ADD R1, R1, #1
			BRnzp converter
			
	;R7 will check if the number input is a negative
	;two's complement of number will convert it to negative	
	;R6 will check if the number is within -511 and +511
	completed 	ADD R0, R0, #0
			BRn invalidPrint		;if number is negative it is out of 16-bit range
			LD R6, rangeCheck
			ADD R6, R0, R6	
			BRzp invalidPrint		;if value is zero or negative then absolute value
							;of the number is greater than 511, is invalid

			ADD R7, R7, #-1			;subtracting one from R7, if zero then number is negative
			BRz twoComplement
			
			BRnzp binary

	;converts number in R0 to it's negative self
	twoComplement	NOT R0, R0
			ADD R0, R0, #1


	;registers used for 'binary and 'maskCheck'
	;R0 is used for printing and work space
	;R1 will store the number
	;R2 will count how many bits have been printed, 16 needed
	;R3 will hold the address of the mask
	binary 		AND R2, R2, #0
			ADD R1, R0, #0
			BRzp maskCheck
			


	;this section ANDS the number in R1 with binary numbers stored in a mask
	;postive(1) AND comparisons will print '1', the result of zero will print '0'
	;
	maskCheck	LEA R3, B_MASK
			ADD R0, R2, #-16
			BRz finish			;if count is 16 then no more bits required to print
			ADD R3, R3, R2			;choose R2 index of mask
			LDR R0, R3, #0			;load binary number from mask 
			ADD R2, R2, #1			;increment count by one

			AND R0, R0, R1			;ANDS original number with mask binary number
			BRnp printOne			;if result is a positive, or negative then '1' is printed
			Brz printZero			;if result is zero, then '0' is printed


	printOne 	LEA R0, one
			puts
			BRnzp maskCheck	

	printZero 	LEA R0, zero
			puts
			BRnzp maskCheck	


	finish halt
			
	end_signal	.FILL x21			;ASCII for '!'
	end_minus	.Fill x-21
	
	enter .stringz "Enter an integer between -511 and +511: "
	PLUS .fill x-2B			;ascii offset for positive sign
	NEGATIVE .fill x-2D		;ascii offset for negative sign
	invalid .stringz "The input is invalid.\n"
	ASCII .fill x-30 		;negative ascii offset
	number .blkw 80			;number buffer for user input

	one .stringz "1 "
	zero .stringz "0 "

	rangeCheck .fill #-512
	
	;binary mask(16bit)
	B_MASK  .FILL   b1000000000000000	
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
	
	.end
