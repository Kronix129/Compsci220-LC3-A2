;nhow741
;this program find the location (i.e. the bit number corresponding to the location 
;of the first '1' in a number 


			;R2 is used as the position of the index
			;R0 will store the number		

			.ORIG x3000
			ADD R2, R2, #15
			LD R0, number

			;at every iteration, index will decrease by one
			;number in R0 will be shifted 
			;if number is neagitive, first '1' has been found
	loop 		BRn negative
			ADD R2, R2, #-1
			ADD R0, R0, R0
			BRnzp loop

			;R0 stores string which is outputted to screen
	negative 	LEA R0, sig_print
			puts
			LD R5, ASCII		;stores ASCII value
			ADD R0, R2, #-10	;method to check if position number is above/below ten
			BRn belowTen

			;if number is above 10, needs to be a special output
			;one is printed first
			AND R0, R0, #0		
			ADD R0, R0, #1
			ADD R0, R0, R5		
			out
			
			;this section subtracts position by 10 to find the second digit 
			;second digit then printed after 1
			AND R0, R0, #0 
			ADD R0, R2, #-10
			ADD R0, R0, R5
			out
			halt


	belowTen 	ADD R0, R2, R5
			out
			halt


 

number .fill b0100000000000001
sig_print .STRINGZ "The first significant bit is "
ASCII .fill x30

.end
