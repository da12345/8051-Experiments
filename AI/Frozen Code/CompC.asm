;ASTER 01/03/2009 1545
;TO BE ASSEMBLED IN KEIL MICROVISION V3.60
;ARTIFICIAL INTELLIGENCE
;MICROCOMPUTER C

;CODE BASE COMPLETED : 02/03/2009 2120

;REV 3 LAST UPDATED 28/04/2009 1445
;REV 4 LAST UPDATED 18/06/2009 1722
;CODE CLOSED 21/06/2009	2213 ::: WORKING TESTED ::: PERFECT

;-----------------------------------------------------------------------------------------------------------
;SET THE ASSEMBLER FOR AT89S52
$NOMOD51
$INCLUDE (AT89X52.h)

;DEFINITIONS
SBIT RS=P0^7
SBIT RW=P0^6
SBIT EN=P0^5
SBIT SYSBUSY=P1^7
;-----------------------------------------------------------------------------------------------------------

ORG 0000H

RESET:		SJMP 0030H 

ORG 0030H

START:		NOP
			MOV SP,#10H					;RELOCATE STACK OVER 10H 

INIT:		MOV A,#38H					;INITIALIZATION OF HD44780(LCD CONTROLLER)
			LCALL COMMAND
			MOV A,#0CH
			LCALL COMMAND
			
			MOV A,#38H					;REINITIALIZATION OF HD44780 FOR CAPACITIVE CORRECTION
			LCALL COMMAND
			MOV A,#0CH
			LCALL COMMAND
			MOV A,#06H
			LCALL COMMAND
			MOV A,#01H	
			LCALL COMMAND

			MOV DPTR,#MSG1			 	;DISPLAY SOMETHING
			LCALL WRITEALL

			CLR A					 	;PORTS'  INIT
			MOV A,#0FFH
			MOV P3,A
			MOV P0,#0FFH
			MOV P1,A
			SETB P1.7 					;PULL UP BUSY FLAG

			MOV R0,#20H				 	;CLEAR RAM FROM 20H TO 7FH
			CLR A
CLE:		MOV @R0,A
			INC R0
			CJNE R0,#7FH,CLE

			
			MOV T2CON,#30H				;SERIAL BAUD GENERATOR INIT 9600BPS TWI
			MOV RCAP2H,#0FFH
			MOV RCAP2L,#0DCH
			ANL PCON,#7FH
			MOV SCON,#58H

			
			MOV TCON,#01H
			MOV IE,#91H				  	;INTERRUPTS ENABLE : INT0, SERIAL
			MOV IP,#10H
			
			SETB TR2				  	;START BAUD TIMER

			SETB PSW.3					;SERIAL RX BUFFER FROM 40H TO 4FH
			MOV R0,#40H
			CLR PSW.3


			MOV A,#2EH
			LCALL DISPLAY				;DOT 1		  	
			LCALL DELAYD
			
COMLOAD:	MOV A,#61H
			MOV R0,#61H
RPTA:		MOV @R0,A
			INC R0
			INC A
			CJNE A,#80H,RPTA
			
			MOV A,#2EH				
			LCALL DISPLAY				;DOT 2
			LCALL DELAYD				
			LCALL DISPLAY			  	;DOT 3
			LCALL DELAYD
			LCALL DISPLAY			  	;DOT 4
			LCALL DELAYD

			
			
			LCALL CLEARH			 	;CLEAR THE LCD AND HOME CURSOR
			MOV R0,#3FH

;--------------------------------------------------------------------------------------------------
;**************************************************************************************************
;PROGRAM MAIN
;MAIN BEGINS HERE

MAIN:		MOV A,#01H
			LCALL COMMAND
			MOV DPTR,#MSG4
			LCALL LCDWRITE
			NOP
NEXTS:		JB 79H,POWERDWN				;JUMP TO POWERDOWN IF 79H IS SET
			INC R0
			MOV A,@R0
			CJNE R0,#50H,CONTI
			MOV R0,#40H
CONTI:		JZ NEXTS

			MOV @R0,#00H			  	;CLEAR THE READ SPACE

			CJNE A,#61H,VERFLL
VERFLL:		JC EXITF
			CJNE A,#80H,VERFLU
VERFLU:		JNC EXITF

			MOV DPTR,#MSG5
			CLR C
			SUBB A,#61H
			MOV B,#33
			MUL AB
			ADD A,DPL
			MOV DPL,A
			MOV A,B
			ADDC A,DPH
			MOV DPH,A

			CLR A						
			LCALL LCDWRITE				;'LCDWRITE' MODIFIES CONTENTS OF R2,BANK0
			LCALL DELAYL				;DISPLAY CURRENT OPERATION INFORMATION

CHBUSY:	 	JNB SYSBUSY,CHBUSY			;WAIT FOR MICRO B TO FINISH CURRENT OPERATION


EXITF:		NOP

										
MAIN_END:	LJMP MAIN					;LOOP THE MAIN

;PROGRAM MAIN ENDS HERE
;******************************************************************************************
;------------------------------------------------------------------------------------------
;POWER DOWN IN CASE OF BATTERY BROWN OUT
POWERDWN:	NOP
			CLR IE.7				;DISABLE ALL INTERRUPTS
			LCALL CLEARH
			MOV DPTR,#MSG29
			LCALL WRITEALL
			MOV PCON,#02H			;PUT MC INTO POWERDOWN MODE
			NOP
HALTDC:		SJMP HALTDC

;LCD ROUTINES

COMMAND:	LCALL READY
			CLR RW
			CLR RS
			MOV P2,A
			SETB EN
			NOP 
			CLR EN
			RET

DISPLAY:	LCALL READY
			CLR RW
			SETB RS
			MOV P2,A
			SETB EN
			NOP
			CLR EN
			RET

READY:		SETB P2.7
			CLR RS
			SETB RW
BUSY:		CLR EN
			SETB EN
			JB P2.7,BUSY
			NOP
			CLR EN
			RET

CLEARH:		MOV A,#01H						;CLEAR DISPLAY AND HOME CURSOR
			LCALL COMMAND
			RET

RSHIFTC:	MOV A,#14H						;SHIFT CURSOR RIGHT BY COUNT IN B
SHRIGHT:	LCALL COMMAND
			DJNZ B,SHRIGHT
			RET
			
WRITEALL:	CLR A						  	;WRITE ALL POINTED BY DPTR
			MOVC A,@A+DPTR
			JZ EXITWR
			INC DPTR
			LCALL DISPLAY
			SJMP WRITEALL
EXITWR:		NOP
			RET


LCDWRITE:	MOV A,#01H
			LCALL COMMAND					;UPDATE LCD UPPER LINE
			MOV R2,#10H
DISPU:		CLR A
			MOVC A,@A+DPTR
			LCALL DISPLAY
			INC DPTR
			DJNZ R2,DISPU
LCDWRITEL:	MOV A,#0C0H				  		;UPDATE LCD LOWER LINE
			LCALL COMMAND
			MOV R2,#10H
DISPL:		CLR A
			MOVC A,@A+DPTR
			LCALL DISPLAY
			INC DPTR
			DJNZ R2,DISPL
			RET
;-------------------------------------------------------------------------------------------
;INTERRUPT SERVICE ROUTINES

;SERIAL INTERRUPT : SERIAL
;SERIAL RECEPTION OR TRANSMISSION COMPLETE
ORG 0023H
			LJMP 1000H
ORG 1000H

SERCON:		CLR TR2
			PUSH ACC
			SETB PSW.3
			JNB RI,TXI
			CLR RI
			MOV A,SBUF
			CJNE A,#'Z',PWRSAFE			;CHECK IF POWER DOWN IS ISSUED
			SETB 79H					;SET 79H IF POWERDOWN IS NEEDED
			SJMP EXITC
PWRSAFE:	CJNE R0,#50H,CONTC
			MOV R0,#40H
CONTC:		MOV @R0,A
			INC R0
			SJMP EXITC
TXI:		CLR TI
EXITC:		POP ACC
			SETB TR2
			CLR PSW.3
			RETI 
;-------------------------------------------------------------------------------------------
;OTHER SUBROUTINES

;DELAY DISPLAY & SYNC
DELAYD:		MOV R7,#06H
			MOV R6,#0FFH
			MOV R5,#0FFH
			DJNZ R5,$
			DJNZ R6,$-2
			DJNZ R7,$-4
			RET

;DELAY LCD DISPLAY
DELAYL:		MOV R7,#06H
			MOV R6,#0FFH
			MOV R5,#0FFH
			DJNZ R5,$
			DJNZ R6,$-2
			DJNZ R7,$-4
			RET

;DELAY DISPLAY
DELAYF:		MOV R7,#0FFH
			DJNZ R7,$
			RET

			
;HEX TO ASCII CONVERTER
CONVERT:	MOV B,#100
			DIV AB
			ORL A,#30H
			MOV 63H,A
			MOV A,B
			MOV B,#10
			DIV AB
			ORL A,#30H
			MOV 64H,A
			MOV A,B
			ORL A,#30H
			MOV 65H,A
			RET

 
;-------------------------------------------------------------------------------------------
;DISPLAY DATA

ORG 1A00H

MSG1:	DB 'INITIALIZING',00H,00H,00H,00H,00H
MSG2:	DB '////////////////////////////////',00H,00H
MSG3:	DB '00 MICRO 0 BUSY ',00H
MSG4:	DB 'RXD CH0-1 IDLE  MICRO B IDLE    ',00H
MSG5:	DB 'CLOSING CLASPER 61 MICRO B BUSY ',00H	;61H RIGHT	'a'
MSG6:	DB 'OPENING CLASPER 62 MICRO B BUSY ',00H	;62H RIGHT	'b'
MSG7:	DB 'RITE SHOULDER UP63 MICRO B BUSY ',00H	;63H		'c'
MSG8:	DB 'LEFT SHOULDER UP64 MICRO B BUSY ',00H	;64H		'd'
MSG9:	DB 'RGT SHOULDER DWN65 MICRO B BUSY ',00H	;65H		'e'
MSG10:	DB 'LFT SHOULDER DWN66 MICRO B BUSY ',00H	;66H		'f'
MSG11: 	DB 'RIGHT FOREARM UP67 MICRO B BUSY ',00H	;67H		'g'
MSG12:	DB 'LEFT FOREARM UP 68 MICRO B BUSY ',00H	;68H	   	'h'
MSG13:	DB 'RGT FOREARM DOWN69 MICRO B BUSY ',00H	;69H		'i'
MSG14:	DB 'LFT FOREARM DOWN6A MICRO B BUSY ',00H	;6AH		'j'
MSG15:	DB 'MOVING FORWARD  6B MICRO B BUSY ',00H	;6BH		'k'
MSG16: 	DB 'MOVING BACKWARD 6C MICRO B BUSY ',00H	;6CH		'l'
MSG17:	DB 'TURNING RIGHT   6D MICRO B BUSY ',00H	;6DH		'm'
MSG18:	DB 'TURNING LEFT    6E MICRO B BUSY ',00H	;6EH		'n'
MSG19:	DB 'CLOSING CLASPER 6F MICRO B BUSY ',00H	;6FH LEFT 	'o'
MSG20:	DB 'OPENING CLASPER 70 MICRO B BUSY ',00H	;70H LEFT	'p'
MSG21:	DB 'STOPPING        71 MICRO B BUSY ',00H	;71H		'q'
MSG22:	DB 'RGT SHOULDER STP72 MICRO B BUSY ',00H	;72H RIGHT SHOULDER STOP	'r'
MSG23:	DB 'LFT SHOULDER STP73 MICRO B BUSY ',00H	;73H LEFT SHOULDER STOP	   	's'
MSG24:	DB 'RGT FOREARM STOP74 MICRO B BUSY ',00H	;74H RIGHT FOREARM STOP		't'
MSG25:	DB 'LFT FOREARM STOP75 MICRO B BUSY ',00H	;75H LEFT FOREARM STOP	   	'u'
MSG26:	DB 'TURNING HEAD RGT76 MICRO B BUSY ',00H	;76H TURN HEAD RIGHT	   	'v'
MSG27:	DB 'TURNING HEAD LFT77 MICRO B BUSY ',00H	;77H TURN HEAD LEFT		   	'w'
MSG28:	DB 'HALTING HEAD    78 MICRO B BUSY ',00H	;78H STOP HEAD MOTION	   	'x'
MSG29:	DB 'RECHARGE & RESET',00H
;------------------------------------------------------------------------------------------- 
;-------------------------------------------------------------------------------------------
END
