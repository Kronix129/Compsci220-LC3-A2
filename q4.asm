	;nhow741
	;this program will accept a number between -511 and +511
	;it will output the binary version of the number to the screen
	;it will also output the number as a 16-bit floating point number 
	;program implements subroutines throughout
			.orig x3000

	start		jsr get_number
			jsr convert_number	; R0 returns xffff if invalid, otherwise the converted integer
			add R1, R0, #1
			BRz start
			jsr print_binary	;prints R0 as binary
			jsr convert_float	;prints R0 as binary
			jsr print_binary
			halt

	
;---------------------------------------------------------------------------------------------------------------

	get_number	st R0, GN0
			st R1, GN1
			st R2, GN2
			st R7 GN_ret
			
			AND R6, R6, #0		;this will be used later to mark a number as negative
			LEA R0, enter		;R6 must be reset everytime a new input is made
			puts
			LEA R1, number
			BRnzp char

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
	stop		LD R3, end_signal
			str R3, R1, #0		;new

			ld R0, GN0
			ld R1, GN1
			ld R2, GN2
			ld R7 GN_ret		
			RET


;storage for register values in 'get_number' subroutine
GN0	.blkw 1
GN1	.blkw 1
GN2	.blkw 1
GN_ret	.blkw 1


end_signal	.FILL x21
enter .stringz "Enter an integer between -511 and +511: "
number .blkw 80		;number buffer for user input

;---------------------------------------------------------------------------------------------------------------
	
	;takes the first character of number, checks if it is a + sign
	;R2 stores ascii of plus, and turns it into it's negative value	
	convert_number	st R1, CN1
			st R2, CN2
			st R3, CN3
			st R4, CN4
			st R5, CN5
			st R7, CN_ret 
			
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
			ld R1, CN1
			ld R2, CN2
			ld R3, CN3
			ld R4, CN4
			ld R5, CN5
			ld R7, CN_ret
			AND R0, R0, #0 
			ADD R0, R0, xffff
			RET


	validSign	LD R3, NEGATIVE
			ADD R0, R2, R3
			BRz negTrack			;method to check if operator is negative
			ADD R1, R1 #1			;increments adress past operator sign
			LD R2, ASCII			;loads negative ASCII offset
			AND R0, R0, #0			;clears R0
			BRnzp converter

	
	;adds the value 1 to register 6 to signal number is negative
	;register 6 will be referenced again later to check it number was negative	
	negTrack	AND R6, R6, #0
			ADD R6, R6, #1
			ADD R1, R1, #1
			LD R2, ASCII
			AND R0, R0, #0


	;part will convert string of digits into an integer
	;R0 will store the integer
	;R1 will point to characters in the buffer
	;R2 will hold the negative ascii offset 
	;R3, R4, R5 work space
	converter	LDR R3, R1, #0			;loads character into R3
			LD R4, end_minus	
			ADD R4, R3, R4
			BRz completed	
		
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



	;R6 will check if the number input is a negative
	;two's complement of number will convert it to negative	
	;R5 will check if the number is within -511 and +511
	completed 	ADD R0, R0, #0
			BRn invalidPrint		;if number is negative it is out of 16-bit range, therefore invalid
			LD R5, rangeCheck
			ADD R5, R0, R5	
			BRzp invalidPrint		;if value is zero or negative then absolute value
							;of the number is greater than 511, is invalid

			ADD R6, R6, #-1			;subtracting one from R6, if zero then number is negative
			BRz twoComplement
			ld R1, CN1
			ld R2, CN2
			ld R3, CN3
			ld R4, CN4
			ld R5, CN5
			ld R7, CN_ret
			RET


	;converts number in R0 to it's negative self
	twoComplement	NOT R0, R0
			ADD R0, R0, #1
			ADD R6, R6, #1			;adds 1 back to R6 to note negative number
			ld R1, CN1
			ld R2, CN2
			ld R3, CN3
			ld R4, CN4
			ld R5, CN5
			ld R7, CN_ret
			RET

end_minus .FILL x-21
PLUS .fill x-2B		;ascii offset for positive sign
NEGATIVE .FILL x-2D	;ascii offset for negative sign
invalid .stringz "The input is invalid.\n"
ASCII .FILL x-30 	;negative ascii offset
rangeCheck .FILL #-512

;storage for register values in 'convert_number' subroutine
CN1	.blkw 1
CN2	.blkw 1
CN3	.blkw 1
CN4	.blkw 1
CN5	.blkw 1
CN_ret	.blkw 1


one .stringz "1 "
zero .stringz "0 "
;---------------------------------------------------------------------------------------------------------------

	 
	;R0 is used for printing and work space
	;R1 will store the number
	;R2 will count how many bits have been printed, 16 needed
	;R3 will hold the address of the mask
	print_binary	ST R0, PB0
			ST R1, PB1
			ST R2, PB2
			ST R3, PB3
			ST R7, PB_ret
			AND R2, R2, #0
			ADD R1, R0, #0
			BRzp maskCheck


	;this section ANDS the number in R1 with binary numbers stored in a mask
	;postive(1) AND comparisons will print one, the result of zero will print zero
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

	finish 		AND R0, R0, #0
			ADD R0, R0, xA
			out
			LD R0, PB0
			LD R1, PB1
			LD R2, PB2
			LD R3, PB3
			LD R7, PB_ret
			RET

;binary mask
B_MASK  	.FILL   b1000000000000000	
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

;storage for register value in 'print_binary' subroutine
PB0	.blkw 1
PB1	.blkw 1
PB2	.blkw 1
PB3	.blkw 1
PB_ret	.blkw 1

;---------------------------------------------------------------------------------------------------------------
	
	;R0 currently holds the input number
	;If R0 is a negative number, it needs to be converted back to positive
	;R1 will hold the number
	;R2 will be the count of the significant bit index 
	;R2 will be needed later for determining amount to shift input number
	convert_float	ST R1, CF1
			ST R2, CF2
			ST R3, CF3
			ST R4, CF4
			ST R7, CF_ret

			AND R2, R2, #0		;clear count
			ADD R2, R2, #15		
			AND R1, R1, #0
			ADD R1, R0, #0
			ADD R0, R0, #0
			BRn pos_convert
			BRp loop

			;if number isn't negative or positive, then it is +0
			;+0 is a special case and is immediately returnd
			LD R1, CF1
			LD R2, CF2
			LD R3, CF3
			LD R4, CF4
			LD R7, CF_ret
			RET			
			
			

	pos_convert	NOT R0, R0
			ADD R0, R0, #1		;R0 is now absolute value
			ADD R1, R0, #0
			
			
	loop 		BRn exponent		;if number is negative, leading bit must be one
			ADD R2, R2, #-1		;if not negative, reduce index by one
			ADD R1, R1, R1		;shift number 
			BRnzp loop

	;R3 will now hold the exponent (index + 7)
	exponent	ADD R3, R2, #7	
	
	;loop will add number stored in R3 to itself, 11 times
	;R1 will track number of times added
	;R4 will check if the loop has executed 11 times
			AND R1, R1, #0
			
	shift		ADD R1, R1, #1	
			ADD R3, R3, R3
			ADD R4, R1, #-11
			BRz expo_and
			BRnzp shift

	
	;once exponent has been shifted, R3 is then converted to 16-bit via and AND instruction
	;R1 will hold the 16 bit number for the AND
	;R1 will store the final output
	;R3 holds the exponent value and will be used for the AND

	expo_and	LD R1, positive_and
			AND R1, R1, R3
			BRnzp shift_input
	
	;R1 currently holds the ANDED exponent 
	;R2 currently holds index of first significant figure (1)
	;R3 will track amount of times number has been shifted
	;shift input determines the amount to shift the input number
	;shift = 11 - index
			
	shift_input	NOT R2, R2
			ADD R2, R2, #1
			AND R3, R3, #0
			ADD R3, R2, #11		;R3 now holds amount to be shifted		
	
	;loop which shifts loop 11 - index amount of times		
	 input_loop	ADD R0, R0, R0
			ADD R3, R3, #-1
			BRz remove_first
			BRnzp input_loop
	
	;once number has been shifted, the first one needs to be removed
	;shifted number needs to be ANDED
	;R2 will store the binary AND number
	 remove_first	LD R2, first_and
			AND R0, R0, R2

	;R0 now holds shifted input number, with fist 1 removed
	;R0 will hold the final format to be printed
	;R1 holds the exponent with either a 1 or 0 infront
	;R0 and R1 need to be OR'd together to combine the two for 16-bit format
	final_format	NOT R0, R0
			NOT R1, R1
			AND R0, R0, R1
			NOT R0, R0
			
			ADD R6, R6, #-1
			BRz first_bit
			LD R1, CF1
			LD R2, CF2
			LD R3, CF3
			LD R4, CF4
			LD R7, CF_ret
			RET
			
	
	;input number was negative, therefore first bit of 16 should be a one
	;R0 will be OR'd with b1000000000000000	
	;R1 will store the binary number used in OR
	first_bit	LD R1, negative_or
			NOT R0, R0
			NOT R1, R1
			AND R0, R0, R1
			NOT R0, R0
			LD R1, CF1
			LD R2, CF2
			LD R3, CF3
			LD R4, CF4
			LD R7, CF_ret
			RET
			

;storage for register value in 'convert float' subroutine

CF0	.blkw 1
CF1	.blkw 1
CF2	.blkw 1
CF3	.blkw 1
CF4	.blkw 1
CF_ret	.blkw 1

positive_and	.FILL	b0111100000000000
negative_or	.FILL	b1000000000000000
first_and	.FILL 	b011111111111

.end
		
