;RECEIVER 1

$NOMOD51
$INCLUDE (AT89X52.h)


ORG 0000H
SJMP 0030H
ORG 0030H



START:		MOV P3,#0FFH
			MOV P2,#00H
			
			MOV T2CON,#30H
			MOV RCAP2H,#0FFH
			MOV RCAP2L,#0DCH
			
			ANL PCON,#7FH
			
			MOV IE,#90H
			MOV IP,#10H
			
			MOV SCON,#58H
			SETB TR2

			CLR A
			MOV 23H,A 
			MOV 24H,A
			MOV 25H,A
			MOV 26H,A
			MOV 27H,A
			MOV 28H,A


MAIN:		NOP
WAITR:		JNB 20H,WAITR
WAIT2:		JNB 21H,WAIT2
			CLR 21H
			MOV P2,A
WAIT3:		JB 20H,WAIT3

HERE:		SJMP HERE

;----------------------------------------------
ORG 0023H
LJMP 1000H
ORG 1000H

SERCON:		CLR TR2
			JNB RI,TXI
			CLR RI
			MOV A,SBUF
			JB 20H,SKIPC
			CJNE A,#0CDH,EXITC
			MOV SBUF,#9DH
			SETB 20H
			SJMP EXITC
SKIPC:		CJNE A,#0BDH,SKIPC2
			MOV SBUF,#0BDH
			CLR 20H
			SJMP EXITC
SKIPC2:		SETB 21H
			MOV SBUF,#9DH
			SJMP EXITC
TXI:		CLR TI
EXITC:		SETB TR2
			RETI
;-----------------------------------------------

END

