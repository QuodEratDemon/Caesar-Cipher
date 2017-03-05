
	.ORIG x3000


begin	LEA R0, start 	;starting message
	PUTS

restart	LEA R0, askfor 	;begin/restart program
	PUTS		;ask for a command
	AND R0, R0, 0 	;empty every registry
	AND R1, R1, 0 	;R1 will be a flag
	AND R2, R2, 0	;R2 will be Ri/Temp
	AND R3, R3, 0 	;Ci/temp
	AND R4, R4, 0	;digit/char/temp
	AND R5, R5, 0	;stores the cipher
	AND R6, R6, 0	;only for Temp, always safe to use/clear
	AND R7, R7, 0	;Temp
	BR getLF	;take input

getLF	GETC		;get the user input
	OUT
	LD R6, isx
	ADD R4, R0, R6 	;if char == x
	BRz exit	;exit program
	AND R4, R4, 0
	AND R6, R6, 0	
	LD R3, isd
	ADD R4, R0, R3	;if char == d
	BRz decrypt	;decrypt
	AND R4, R4, 0
	AND R6, R6, 0	
	LD R6, ise
	ADD R4, R0, R6	;if char == e
	BRz encrypt	;encrypt
	BR restart	;else restart the program

decrypt	LEA R0, getci
	PUTS
	AND R0, R0, 0
	ADD R1, R1, 1	; Set flag = 1
	BR cipher

encrypt	LEA R0, getci
	PUTS
	AND R0, R0, 0
	AND R1, R1, 0	; Set flag = 0
	BR cipher

cipher	GETC	
	OUT
	ADD R4, R0, -10	; check if char == LF
	BRZ msg		; if yes then continue on 
	AND R4, R4, 0
	ADD R4, R4, R0
	LD R6, ascii
	ADD R4, R4, R6	;digit = char -48
	JSR mult10
	ADD R5, R5, R4	;cipher=R5*10 + digit
	BR cipher	; repeat until cipher is stored in R5

mult10	AND R2, R2, 0	;multiplies R5 by 10
	AND R6, R6, 0
	ADD R2, R5, R5
	ADD R6, R2, R2
	ADD R6, R6, R6
	ADD R5, R6, R2
	RET

msg	LEA R0, gets	;prints the message asking for the string
	PUTS
	AND R0, R0, 0
	AND R3, R3, 0
	BR getmsg

getmsg	GETC	;get the char of msg
	OUT
	BR checklf	;check if it is the line feed	

checklf	AND R6, R6, 0
	ADD R6, R0, -10	;check if char ==LF
	BRz print	;if yes then print the array
	AND R2, R2, 0
	JSR store	;Else store the value
	AND R2, R2, 0
	BR crypt	;start encrypting/decrypting

crypt	AND R6, R6, 0
	ADD R6, R1, -1	;if flag = 1 then decrypt
	BRz dec
	AND R6, R6, 0	;else encrypt
	BR enc

dec	JSR dec2
	ADD R3, R3, 1	;increment Ci
	BR getmsg

enc	JSR enc2
	ADD R3, R3, 1	;increment Ci
	BR getmsg


print 	LEA R0, res 	;print result message
	PUTS
	AND R2, R2, 0
	AND R3, R3, 0
	JSR print2	;start printing
	BR restart

exit	LEA R0, gb	;exit the program
	PUTS	;print good bye
	HALT	;end


ascii	.FILL -48	;turn char into decimal
isx	.FILL -120	; check if x, d , or e
isd	.FILL -100
ise	.FILL -101

gb	.STRINGZ "\nGood Bye!\n"
start	.STRINGZ "\nWelcome to Lab4: Caesar Cipher \n"
askfor	.STRINGZ "\nDo you want to (e)ncrypt or (d)ecrypt or e(x)it? (lowercase only)  \n"
gets	.STRINGZ "\nWhat is the string? (up to 200 characters)  \n"
getci	.STRINGZ "\nWhat is the cipher? (1-25)\n"
res 	.STRINGZ "\nHere are the results: "
encmsg	.STRINGZ "\n<encrypted>"
decmsg	.STRINGZ "\n<decrypted>"
pc	.BLKW 1		;for saving R7

shiftnm	.FILL 199	;200-1 because of 0 

store	LEA R6, array	;load the array 
	ADD R6, R6, R2	;add the Ri (should only be <= 200 during encrypting/decrypting)
	ADD R6, R6, R3	;add the Ci
	STR R0, R6, 0	;store the address
	RET

storeck	AND R6, R6, 0	;shifts the array to row 2
	AND R2, R2, 0	;by adding 200
	LD R6, shiftnm	
	ADD R2, R2, R6
	BR store	; now the actual storing

dec2	ST R7, pc	;save the PC (next instruction)
	AND R1, R1, 0	;wont be needing the flag anymore
	AND R6, R6, 0
	AND R7, R7, 0
	LD R1, cap	;check if it is capital letter or num/special
	ADD R6, R0, R1
	BRn decend	;if it is num/special dont rotate
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, alph
	ADD R6, R0, R1	;check if it is a special character
	BRnz deccap	;if not then rotate uppercase 
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, low
	ADD R6, R0, R1	;check if it is a lowercase
	BRn decend	;if not then dont rotate
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, alph2
	ADD R6, R0, R1	;check if it is a special character
	BRnz declow	;if not the rotate lowercase
	BR decend	;if it is then dont rotate

deccap	NOT R5, R5	;invert cipher
	ADD R5, R5, 1 	;2's compliment
	ADD R0, R5, R0	;set the number
	ADD R5, R5, -1
	Not R5, R5	;Turn the cipher back to normal
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, cap
	ADD R6, R1, R0
	BRn offsetd	;change off set if its no longer A-Z
	BR decend

declow	NOT R5, R5	;invert cipher
	ADD R5, R5, 1 	;2's compliment
	ADD R0, R5, R0	;set the number
	ADD R5, R5, -1
	Not R5, R5	;Turn the cipher back to normal
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, low
	ADD R6, R1, R0
	BRn offsetd	;change off set if its no longer a-z
	BR decend

offsetd	AND R1, R1, 0
	LD R1, roll	;roll over
	ADD R0, R0, R1
	BR decend

decend	AND R2, R2, 0
	JSR storeck
	ST R3, length	;store the length of the message
	AND R1, R1, 0
	ADD R1, R1, 1	;reset the flag
	LD R7, pc 	;load in the saved instruction to return properly
	RET

enc2	ST R7, pc	;save the PC (next instruction)
	AND R1, R1, 0	;wont be needing the flag anymore
	AND R6, R6, 0
	AND R7, R7, 0
	LD R1, cap	;check if it is capital letter or num/special
	ADD R6, R0, R1
	BRn encend	;if it is num/special dont rotate
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, alph
	ADD R6, R0, R1	;check if it is a special character
	BRnz enccap	;if not then rotate uppercase 
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, low
	ADD R6, R0, R1	;check if it is a lowercase
	BRn encend	;if not then dont rotate
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, alph2
	ADD R6, R0, R1	;check if it is a special character
	BRnz enclow	;if not the rotate lowercase
	BR encend	;if it is then dont rotate

enccap	ADD R0, R5, R0	;set the number
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, alph
	ADD R6, R1, R0
	BRp offsete	;change off set if its no longer A-Z
	BR encend

enclow	ADD R0, R0, R5	;set the number
	AND R1, R1, 0
	AND R6, R6, 0
	LD R1, alph2
	ADD R6, R0, R1
	BRp offsete	;change off set if its no longer a-z
	BR encend

offsete AND R1, R1, 0
	LD R1, roll2	;roll over
	ADD R0, R0, R1
	BR encend

encend	AND R2, R2, 0
	ADD R2, R2, 1
	JSR storeck
	ST R3, length	;store the length of the message
	AND R1, R1, 0
	LD R7, pc 	;load in the saved instruction to return properly
	RET

load	AND R6, R6, 0
	LEA R6, array	;load in the array
	ADD R6, R6, R2	;get Ri 
	ADD R6, R6, R3	;get Ci
	LDR R0, R6, 0
	RET

load2	AND R6, R6, 0
	LD R6, shiftnm	;shift to row2 by adding 200
	ADD R2, R2, R6
	BR load

print2	ST R7, pc 	;save the program counter to return properly
	AND R4, R4, 0
	AND R6, R6, 0
	AND R7, R7, 0
	LD R4, length	;get the length so it'll know when to stop
	NOT R4, R4	;inverse
	ADD R1, R1, 0
	BRz printe	;if flag was 0 then print encrypt
	BR printd	;else print decrypt

printe	LEA R0, decmsg
	PUTS
	BR arraye

printd	LEA R0, encmsg	;print the initial message
	PUTS
	BR arrayd

arrayd	AND R2, R2, 0	;;print the first row (untouched)
	JSR load
	OUT
	ADD R3, R3, 1
	AND R6, R6, 0
	ADD R6, R4, R3	;checks if it finished
	BRn arrayd	;repeat
	LEA R0, decmsg	;print initial messahe
	PUTS
	AND R3, R3, 0
	BR array2

arraye	AND R2, R2, 0	;print the first row (untouched)
	JSR load
	OUT
	ADD R3, R3, 1
	AND R6, R6, 0
	ADD R6, R4, R3
	BRn arraye	;repeat until done
	LEA R0, encmsg	;print initial message for 2nd row
	PUTS
	AND R3, R3, 0
	BR array2

array2	AND R2, R2, 0 	;print row2 (the rotated message)
	JSR load2
	OUT
	ADD R3, R3, 1
	AND R6, R6, 0
	ADD R6, R3, R4
	BRn array2	;repeat until done
	LD R7, pc 	;load back to return properly
	RET

roll	.FILL 26	;rollover if out of bounds
roll2	.FILL -26
length	.BLKW 1		;temp storage for string length
alph	.FILL -90	;to set the boundries
cap	.FILL -65
low 	.FILL -97
alph2	.FILL -122
array	.BLKW 400	;large array that has to be at the bottom or else

	.END		;DONE!