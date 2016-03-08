;ASTER 02/03/2009 2135
;TO BE ASSEMBLED IN KEIL MICROVISION V3.60
;ARTIFICIAL INTELLIGENCE
;MICROCOMPUTER B

;CODE BASE COMPLETED : 03/03/2009 2251

;REV 3 LAST UPDATED 28/04/2009 1410

;-----------------------------------------------------------------------------------------------------------
;SET THE ASSEMBLER FOR AT89S52
$NOMOD51
$INCLUDE (AT89X52.h)

;DEFINITIONS
SBIT SYSBUSY=P1^7		   				;LOW=> SYSTEM IS HANDLING AN OPERATION
;-----------------------------------------------------------------------------------------------------------
;MICROCOMPUTER INITIALIZATIONS
ORG 0000H

RESET:		SJMP 0030H 

ORG 0030H

START:		NOP
			MOV SP,#10H					;RELOCATE STACK OVER 10H
			 
			CLR A
			MOV P0,A
			MOV P1,A
			MOV P2,A
			MOV P3,#0FFH
			SETB P1.7

			LCALL DELAYIN

			MOV R0,#20H					;CLEAR RAM FROM 20H TO 7FH
			CLR A
CLRALL:		MOV @R0,A
			INC R0
			CJNE R0,#7FH,CLRALL

			
			MOV T2CON,#30H				;SET UP THE UART 9600BPS
			MOV RCAP2H,#0FFH
			MOV RCAP2L,#0DCH
			MOV TMOD,#10H		   		;CONFIGURE TIMER 1 FOR SERVO USE

			ANL PCON,#7FH
			
			SETB PSW.3 					;R0 OF BANK1 POINTS TO COMMAND SPACE(60-67H)
			MOV R0,#60H
			CLR PSW.3

			MOV IE,#90H					;ENABLE INTERRUPTS: SERIAL
			MOV IP,#10H
			
			MOV SCON,#58H
			SETB TR2					;START BAUD GEN TIMER
			MOV R0,#60H


;----------------------------------------------------------------------------------------------------------
;**********************************************************************************************************
;THE PROGRAM MAIN
;PASS DIRECTION IN R2,BANK0 : 00H->FORWARD, 01H->BACKWARD, 02H->ROLL AND STOP, 03H->HARD STOP
;CALL THE CORRESPONDING MOTOR FUNCTION AFTER LOADING R2 WITH THE FUNCTION CODES LISTED ABOVE

MAIN:		MOV A,@R0
			JZ NOCOMM
		  	MOV @R0,#00H				;CLEAR THE PROCESSED COMMAND
			
			CJNE A,#61H,VERFLL			;COMMAND RANGE CHECK
VERFLL:		JC NOCOMM
			CJNE A,#80H,VERFLU
VERFLU:		JNC NOCOMM
			
			
			MOV DPTR,#1000H
			CLR C
			SUBB A,#60H
			MOV B,#16
			MUL AB
			ADD A,DPL
			MOV DPL,A
			MOV A,B
			ADDC A,DPH
			MOV DPH,A

			CLR A
			JMP @A+DPTR
				


NOCOMM:		INC R0
			CJNE R0,#68H,INRAN
			MOV R0,#60H
INRAN:		NOP	
MAIN_END:	LJMP MAIN





;MAIN ENDS HERE
;**********************************************************************************************************
;----------------------------------------------------------------------------------------------------------
;COMMAND PROCESSING

ORG 1010H 	;CLOSE RIGHT CLASPER
CLR SYSBUSY
MOV R2,#00H
LCALL CRGT
SETB SYSBUSY
LJMP NOCOMM

ORG 1020H	;OPEN RIGHT CLASPER
CLR SYSBUSY
MOV R2,#01H
LCALL CRGT
SETB SYSBUSY
LJMP NOCOMM

ORG 1030H	;RIGHT SHOULDER UP
CLR SYSBUSY
MOV R2,#00H
LCALL SHLRGT
LJMP NOCOMM

ORG 1040H  ;LEFT SHOULDER UP
CLR SYSBUSY
MOV R2,#00H
LCALL SHLLFT
LJMP NOCOMM

ORG 1050H	;RIGHT SHOULDER DOWN
CLR SYSBUSY
MOV R2,#01H
LCALL SHLRGT
LJMP NOCOMM

ORG 1060H  ;LEFT SHOULDER DOWN
CLR SYSBUSY
MOV R2,#01H
LCALL SHLLFT
LJMP NOCOMM

ORG 1070H	;RIGHT FOREARM UP
CLR SYSBUSY
MOV R2,#00H
LCALL ELRGT
LJMP NOCOMM

ORG 1080H	;LEFT FOREARM UP
CLR SYSBUSY
MOV R2,#00H
LCALL ELLFT
LJMP NOCOMM

ORG 1090H	;RIGHT FOREARM DOWN
CLR SYSBUSY
MOV R2,#01H
LCALL ELRGT
LJMP NOCOMM

ORG 10A0H	;LEFT FOREARM DOWN
CLR SYSBUSY
MOV R2,#01H
LCALL ELLFT
LJMP NOCOMM

ORG 10B0H	;MOVE FORWARD
CLR SYSBUSY
MOV R2,#00H
LCALL BSERGT
LCALL BSELFT
LJMP NOCOMM

ORG 10C0H	;MOVE BACKWARD
CLR SYSBUSY
MOV R2,#01H
LCALL BSERGT
LCALL BSELFT
LJMP NOCOMM

ORG 10D0H	;TURN RIGHT
CLR SYSBUSY
MOV R2,#00H
LCALL BSELFT
MOV R2,#01H
LCALL BSERGT
LJMP NOCOMM

ORG 10E0H	;TURN LEFT
CLR SYSBUSY
MOV R2,#00H
LCALL BSERGT
MOV R2,#01H
LCALL BSELFT
LJMP NOCOMM

ORG 10F0H	;CLOSE LEFT CLASPER
CLR SYSBUSY
MOV R2,#01H
LCALL CLFT
SETB SYSBUSY
LJMP NOCOMM

ORG 1100H	;OPEN LEFT CLASPER
CLR SYSBUSY
MOV R2,#00H
LCALL CLFT
SETB SYSBUSY
LJMP NOCOMM

ORG 1110H	;MOVEMENT STOP
SETB SYSBUSY
MOV R2,#02H
LCALL BSERGT
LCALL BSELFT
LJMP NOCOMM

ORG 1120H	;RIGHT SHOULDER STOP
SETB SYSBUSY
MOV R2,#03H	
LCALL SHLRGT
LJMP NOCOMM

ORG 1130H	;LEFT SHOULDER STOP
SETB SYSBUSY
MOV R2,#03H
LCALL SHLLFT
LJMP NOCOMM

ORG 1140H	;RIGHT FOREARM STOP
SETB SYSBUSY
MOV R2,#03H
LCALL ELRGT
LJMP NOCOMM

ORG 1150H	;LEFT FOREARM STOP
SETB SYSBUSY
MOV R2,#03H
LCALL ELLFT
LJMP NOCOMM

ORG 1160H	;TURN HEAD RIGHT
CLR SYSBUSY
MOV R2,#00H
LCALL HEADM
LJMP NOCOMM

ORG 1170H	;TURN HEAD LEFT
CLR SYSBUSY
MOV R2,#01H
LCALL HEADM
LJMP NOCOMM

ORG 1180H	;HARD STOP HEAD
SETB SYSBUSY
MOV R2,#03H
LCALL HEADM
LJMP NOCOMM


;----------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------------
;INTERRUPT SERVICE ROUTINES
ORG 0023H
			LJMP 1400H
ORG 1400H

SERCON:		CLR TR2
			PUSH ACC
			JNB RI,TXI
			CLR RI
			MOV A,SBUF
			JB PSW.5,SKIPC
			CJNE A,#31H,EXITC			;PSW.5 SET IMPLIES CONNECTION ESTABLISHED
			MOV SBUF,#31H				;C-ACK 	CONNECT ADDRESS=31H
			SETB PSW.5
			SJMP EXITC
SKIPC:		CJNE A,#32H,SKIPC2		   	;SEND DISCONNECT AND DROP CONNECTION IF DISCONNECT IS RECEIVED
			MOV SBUF,#32H				;D-ACK 	DISCONNECT ADDRESS=32H
			CLR PSW.5
			SJMP EXITC
SKIPC2:		SETB PSW.3				  	;LOAD THE RECEIVED COMMAND IN THE COMMAND SPACE(60-67H)
			MOV @R0,A
			INC R0
			CJNE R0,#68H,INRANGE
			MOV R0,#60H
INRANGE:	MOV SBUF,#39H				;SEND ACK
			CLR PSW.3
			SJMP EXITC
TXI:		CLR TI
EXITC:		POP ACC
			SETB TR2
			NOP
			RETI

;----------------------------------------------------------------------------------------------------------
;MOTOR DRIVING ROUTINES

;MOTOR 1: BASE RIGHT MOTOR :: MOTOR CODE: 01H
BSERGT:		NOP
			CJNE R2,#00H,BACK1
			SETB P2.0
			CLR P2.1
			MOV 34H,#00H
			SJMP DONE1	
BACK1:		CJNE R2,#01H,RSTP1
			CLR P2.0
			SETB P2.1
			MOV 34H,#01H
			SJMP DONE1
RSTP1:		CJNE R2,#02H,HSTP1
			CLR P2.0
			CLR P2.1
			MOV 34H,#04H
			SJMP DONE1
HSTP1:		MOV R3,34H
			CJNE R3,#00H,RREV1
RFOR1:		CLR P2.0
			CLR P2.1
			LCALL DELAYHS
			SETB P2.1
			LCALL DELAYHS
			CLR P2.1
			MOV 34H,#04H
			SJMP DONE1
RREV1:		CJNE R3,#01H,DONE1
			CLR P2.0
			CLR P2.1
			LCALL DELAYHS
			SETB P2.0
			LCALL DELAYHS
			CLR P2.0
			MOV 34H,#04H
DONE1:		NOP
			RET

;MOTOR 2: BASE LEFT MOTOR :: MOTOR CODE: 02H
BSELFT:		NOP
			CJNE R2,#00H,BACK2
			SETB P2.2
			CLR P2.3
			MOV 38H,#00H
			SJMP DONE2	
BACK2:		CJNE R2,#01H,RSTP2
			CLR P2.2
			SETB P2.3
			MOV 38H,#01H
			SJMP DONE2
RSTP2:		CJNE R2,#02H,HSTP2
			CLR P2.2
			CLR P2.3
			MOV 38H,#04H
			SJMP DONE2
HSTP2:		MOV R3,38H
			CJNE R3,#00H,RREV2
RFOR2:		CLR P2.2
			CLR P2.3
			LCALL DELAYHS
			SETB P2.3
			LCALL DELAYHS
			CLR P2.3
			MOV 38H,#04H
			SJMP DONE2
RREV2:		CJNE R3,#01H,DONE2
			CLR P2.2
			CLR P2.3
			LCALL DELAYHS
			SETB P2.2
			LCALL DELAYHS
			CLR P2.2
			MOV 38H,#04H
DONE2:		NOP
			RET

;MOTOR 3: SHOULDER RIGHT MOTOR :: MOTOR CODE: 03H
SHLRGT:		NOP
			CJNE R2,#00H,BACK3
			SETB P2.4
			CLR P2.5
			MOV 3CH,#00H
			SJMP DONE1	
BACK3:		CJNE R2,#01H,RSTP3
			CLR P2.4
			SETB P2.5
			MOV 3CH,#01H
			SJMP DONE3
RSTP3:		CJNE R2,#02H,HSTP3
			CLR P2.4
			CLR P2.5
			MOV 3CH,#04H
			SJMP DONE3
HSTP3:		MOV R3,3CH
			CJNE R3,#00H,RREV3
RFOR3:		CLR P2.4
			CLR P2.5
			LCALL DELAYHS
			SETB P2.5
			LCALL DELAYHS
			CLR P2.5
			MOV 3CH,#04H
			SJMP DONE3
RREV3:		CJNE R3,#01H,DONE3
			CLR P2.4
			CLR P2.5
			LCALL DELAYHS
			SETB P2.4
			LCALL DELAYHS
			CLR P2.4
			MOV 3CH,#04H
DONE3:		NOP
			RET

;MOTOR 4: SHOULDER LEFT MOTOR :: MOTOR CODE: 04H
SHLLFT:		NOP
			CJNE R2,#00H,BACK4
			SETB P2.6
			CLR P2.7
			MOV 40H,#00H
			SJMP DONE4	
BACK4:		CJNE R2,#01H,RSTP4
			CLR P2.6
			SETB P2.7
			MOV 40H,#01H
			SJMP DONE4
RSTP4:		CJNE R2,#02H,HSTP4
			CLR P2.6
			CLR P2.7
			MOV 40H,#04H
			SJMP DONE4
HSTP4:		MOV R3,40H
			CJNE R3,#00H,RREV4
RFOR4:		CLR P2.6
			CLR P2.7
			LCALL DELAYHS
			SETB P2.7
			LCALL DELAYHS
			CLR P2.7
			MOV 40H,#04H
			SJMP DONE4
RREV4:		CJNE R3,#01H,DONE4
			CLR P2.6
			CLR P2.7
			LCALL DELAYHS
			SETB P2.6
			LCALL DELAYHS
			CLR P2.6
			MOV 40H,#04H
DONE4:		NOP
			RET

;MOTOR 5: ARM ELBOW RIGHT MOTOR :: MOTOR CODE : 05H
ELRGT:		NOP
			CJNE R2,#00H,BACK5
			SETB P1.0
			CLR P1.1
			MOV 44H,#00H
			SJMP DONE5	
BACK5:		CJNE R2,#01H,RSTP5
			CLR P1.0
			SETB P1.1
			MOV 44H,#01H
			SJMP DONE5
RSTP5:		CJNE R2,#02H,HSTP5
			CLR P1.0
			CLR P1.1
			MOV 44H,#04H
			SJMP DONE5
HSTP5:		MOV R3,44H
			CJNE R3,#00H,RREV5
RFOR5:		CLR P1.0
			CLR P1.1
			LCALL DELAYHS
			SETB P1.1
			LCALL DELAYHS
			CLR P1.1
			MOV 44H,#04H
			SJMP DONE5
RREV5:		CJNE R3,#01H,DONE5
			CLR P1.0
			CLR P1.1
			LCALL DELAYHS
			SETB P1.0
			LCALL DELAYHS
			CLR P1.0
			MOV 44H,#04H
DONE5:		NOP
			RET

;MOTOR 6: ARM ELBOW LEFT MOTOR :: MOTOR CODE : 06H
ELLFT:		NOP
			CJNE R2,#00H,BACK6
			SETB P1.2
			CLR P1.3
			MOV 48H,#00H
			SJMP DONE6	
BACK6:		CJNE R2,#01H,RSTP6
			CLR P1.2
			SETB P1.3
			MOV 48H,#01H
			SJMP DONE6
RSTP6:		CJNE R2,#02H,HSTP6
			CLR P1.2
			CLR P1.3
			MOV 48H,#04H
			SJMP DONE6
HSTP6:		MOV R3,48H
			CJNE R3,#00H,RREV6
RFOR6:		CLR P1.2
			CLR P1.3
			LCALL DELAYHS
			SETB P1.3
			LCALL DELAYHS
			CLR P1.3
			MOV 48H,#04H
			SJMP DONE6
RREV6:		CJNE R3,#01H,DONE6
			CLR P1.2
			CLR P1.3
			LCALL DELAYHS
			SETB P1.2
			LCALL DELAYHS
			CLR P1.2
			MOV 48H,#04H
DONE6:		NOP
			RET

;MOTOR 7: RIGHT CLASPER :: MOTOR CODE: 07H : SIGNAL ON P1.4
CRGT:		CJNE R2,#00H,CLOPENR
CLCLOSER:	MOV R6,#05H
AGAINR:		MOV R7,#02H
N45MSR:		CLR P1.4
			CLR TR1
			CLR TF1
			MOV TH1,#5DH
			MOV TL1,#0FDH
			SETB TR1
WAITLR:		JNB TF1,WAITLR
			CLR TF1
			DJNZ R7,N45MSR
			CLR TR1
			MOV TH1,#0FDH
			MOV TL1,#0D7H
			SETB P1.4
			SETB TR1
WAITHR:		JNB TF1,WAITHR
			DJNZ R6,AGAINR
			SJMP EXITCR
CLOPENR:	MOV R6,#08H
AGAINRC:	CLR TR1
			MOV TH1,#0E2H
			MOV TL1,#0D7H
			SETB P1.4
			SETB TR1
WAITHRC:	JNB TF1,WAITHRC
			MOV R7,#02H
N45MSRC:	CLR P1.4
			CLR TR1
			CLR TF1
			MOV TH1,#5DH
			MOV TL1,#0FDH
			SETB TR1
WAITLRC:	JNB TF1,WAITLRC
			CLR TF1
			DJNZ R7,N45MSRC
			DJNZ R6,AGAINRC
EXITCR:		CLR TR1
			RET

;MOTOR 8: LEFT CLASPER :: MOTOR CODE : 08H	: SIGNAL ON P1.5
CLFT:		CJNE R2,#00H,CLOPENL
CLCLOSEL:	MOV R6,#0CH
AGAINL:		MOV R7,#02H
N45MSL:		CLR P1.5
			CLR TR1
			CLR TF1
			MOV TH1,#5DH
			MOV TL1,#0FDH
			SETB TR1
WAITLL:		JNB TF1,WAITLL
			CLR TF1
			DJNZ R7,N45MSL
			CLR TR1
			MOV TH1,#0FDH
			MOV TL1,#0D7H
			SETB P1.5
			SETB TR1
WAITHL:		JNB TF1,WAITHL
			DJNZ R6,AGAINL
			SJMP EXITCL
CLOPENL:	MOV R6,#0AH
AGAINLC:	CLR TR1
			MOV TH1,#0E2H
			MOV TL1,#0D7H
			SETB P1.5
			SETB TR1
WAITHLC:	JNB TF1,WAITHLC
			MOV R7,#02H
N45MSLC:	CLR P1.5
			CLR TR1
			CLR TF1
			MOV TH1,#5DH
			MOV TL1,#0FDH
			SETB TR1
WAITLLC:	JNB TF1,WAITLLC
			CLR TF1
			DJNZ R7,N45MSLC
			DJNZ R6,AGAINLC
EXITCL:		CLR TR1
			RET

;MOTOR 9: HEAD MOVEMENT MOTOR :: MOTOR CODE : 09H
HEADM:		NOP
			CJNE R2,#00H,BACK9
			SETB P0.0
			CLR P0.1
			MOV 30H,#00H
			SJMP DONE9	
BACK9:		CJNE R2,#01H,RSTP9
			CLR P0.0
			SETB P0.1
			MOV 30H,#01H
			SJMP DONE9
RSTP9:		CJNE R2,#02H,HSTP9
			CLR P0.0
			CLR P0.1
			MOV 30H,#04H
			SJMP DONE9
HSTP9:		MOV R3,30H
			CJNE R3,#00H,RREV9
RFOR9:		CLR P0.0
			CLR P0.1
			LCALL DELAYHS
			SETB P0.1
			LCALL DELAYHS
			CLR P0.1
			MOV 30H,#04H
			SJMP DONE9
RREV9:		CJNE R3,#01H,DONE9
			CLR P0.0
			CLR P0.1
			LCALL DELAYHS
			SETB P0.0
			LCALL DELAYHS
			CLR P0.0
			MOV 30H,#04H
DONE9:		NOP
			RET

;-------------------------------------------------------------------------------------------------
;DELAY ROUTINES
;DELAY INIT

DELAYIN:	MOV R7,#07H
			MOV R6,#0FFH
			MOV R5,#0FFH
			DJNZ R5,$
			DJNZ R6,$-2
			DJNZ R7,$-4
			RET

DELAYHS:	MOV R7,#0A0H
			DJNZ R7,$
			RET

DELAYFOR:	MOV R7,#0FH
			MOV R6,#0FFH
			MOV R5,#0FFH
			DJNZ R5,$
			DJNZ R6,$-2
			DJNZ R7,$-4
			RET


;--------------------------------------------------------------------------------------------------
END