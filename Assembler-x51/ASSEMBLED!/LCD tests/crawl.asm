;16 ALPHA END TO END NON-CONTINUOUS CRAWLING DISPLAY
;10/08/2007
;CHECKED AND TESTED ON AT89C51
;PROGRAM RUN--------SUCCESS




ORG 0000H 				; P1.1-RS
SJMP 0030H				; P1.2-R/W
ORG 0030H 				; P1.3-EN
					; PORT2 FOR DATA OUT



START:	CLR A 
	MOV P1,A
	MOV P2,A
	MOV P3,A
	


INIT:	MOV A,#38H
	LCALL COMMAND
	MOV A,#0CH
	LCALL COMMAND
	MOV A,#06H
	LCALL COMMAND
	MOV A,#01H
	LCALL COMMAND


RWRITE:	LCALL CLEAR
	CLR A 
	MOV R1,A
	MOV R0,#0CFH
	MOV R2,A
	
CYCLE:	MOV DPTR,#0F80H
	MOV A,R0
	LCALL COMMAND
	INC R2
	MOV R1,#00H
	DEC R0
LOOP:	CLR A
	MOVC A,@A+DPTR
	LCALL DISPLAY
	INC DPTR
	INC R1
	MOV A,R1
	CJNE A,02H,LOOP
	LCALL DELAY
	CJNE R2,#10H,CYCLE	
	SJMP RWRITE
	
	
HERE:	SJMP HERE




COMMAND:LCALL READY
	CLR P1.2
	CLR P1.1
	MOV P2,A
	SETB P1.3
	NOP
	CLR P1.3
	RET


READY: 	SETB P2.7
	CLR P1.1
	SETB P1.2
BUSY:	CLR P1.3
	SETB P1.3
	JB P2.7,BUSY
	NOP 
	CLR P1.3
	RET


DISPLAY:LCALL READY
	CLR P1.2
	SETB P1.1
	MOV P2,A
	SETB P1.3
	NOP
	CLR P1.3
	RET


DELAY:  MOV R7,#04H
WAITC:	MOV R6,#0FFH
WAITB:	MOV R5,#0FFH
WAITA:	DJNZ R5,WAITA
	DJNZ R6,WAITB
	DJNZ R7,WAITC
	RET

	
CLEAR:	MOV A,#01H
	LCALL COMMAND
	RET




ORG 0F80H

		DB 'CRAWLING        '
END