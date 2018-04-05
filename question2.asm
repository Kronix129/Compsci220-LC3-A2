			.orig x3000
			LEA R0, enter
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

	done 		LEA R0, yay
	     		puts
	     		halt

	
	;takes the first character of number, checks if it is a + sign
	;R2 stores ascii of plus, and turns it into it's negative value
	stop		LEA R1, number
			LDR R1, R1, #0
			LD R2, PLUS		;loads ascii for plus sign 
			NOT R2, R2
			ADD R2, R2, #1		;turns plus sign value into negative
			ADD R0, R2, R1		;subtracts first character value of 'number' with negative plus value
			BRz done		;if CC = 0 then first character was plus sign 
				 
		
	;first character still might be a '-' sign, this part checks for that
			LEA R1, number
			LDR R1, R1, #0
			LD R2, NEGATIVE		;loads ascii for negative sign
			NOT R2, R2
			ADD R2, R2, #1
			ADD R0, R2, R1
			BRz done

	;if first character is not '+' or '-' then it is invalid
			LEA R0, invalid
			puts
			halt

			
			
		
	



	enter .stringz "Enter an integer between -511 and +511: "
	PLUS .fill x2B
	NEGATIVE .fill x2D
	yay .stringz "done it nigga"
	invalid .stringz "The input is invalid."
	number .blkw 10
	.end
