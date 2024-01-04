ORG 00H 
mov p1.0,c
ACALL SERIAL_INT ; 
MAIN_STR: 
ACALL REC_MOD 
MOV A, R6 
CLR C 
SUBB A, #30H 
MOV R3, A         ;first num      
 
ACALL REC_MOD 
MOV 04, R6           ;operation
 
ACALL REC_MOD 
MOV A, R6 
CLR C 
SUBB A, #30H 
MOV R5, A                 ;second num
; *********** -- "CALCULATE" -- ****************** 
ADD_OPERATION: 
	 	CJNE R4, #43, SUB_OPERATION 
	 	MOV A, R3 
	 	ADD A, R5 
	 	ACALL PRINT 
 	SJMP ALL_FINISHED 
	SUB_OPERATION: 
	 	CJNE R4, #45, MUL_OPERATION 
	 	MOV A, R3 
	 	CLR C 
	 	SUBB A, R5  ;R3-R5
	 	JNC PRINT1 
	 	MOV A,#45 
	 	ACALL SEND_MOD 
	 	MOV A, R5 
	 	CLR C 
	 	SUBB A, R3  ;R3-R5
	 	PRINT1: ACALL PRINT 
 	SJMP ALL_FINISHED 
	MUL_OPERATION: 
	 	CJNE R4, #120, DIV_OPERATION 
	 	MOV A, R3 
	 	MOV B, R5 
	 	MUL AB 
	 	ACALL PRINT 
 	SJMP ALL_FINISHED 
	DIV_OPERATION: 
	 	MOV A, R5 
	 	JZ ERROR1  
	 	MOV A, R3 
	 	MOV B, R5 
	 	DIV AB 
	 	ACALL PRINT 
	 	MOV A, #46 
	 	ACALL SEND_MOD 
	 	MOV A, #10 
	 	MUL AB  
	 	MOV B, R5 
	 	DIV AB 
	 	ACALL PRINT 
	 	SJMP ALL_FINISHED 
	 	ERROR1: MOV DPTR, #ERROR 
	 	ACALL MESSAGE 
;*********** -- "FINISH" -- ****************** 
ALL_FINISHED: MOV A, #'$' 
ACALL SEND_MOD 
SJMP MAIN_STR ;***************************** 
MESSAGE:  
AGAIN: MOV A, #0 
	 	   MOVC A, @A+DPTR 
	 	   JZ FINISH 
	 	   ACALL SEND_MOD 
	 	   INC DPTR 
	 	   SJMP AGAIN 
FINISH: RET 
;*****************************
PRINT:  
	 	MOV R6,A 
	 	CLR C 
	 	SUBB A, #10    
	 	JNC NOT_YET 
	 	MOV A, R6 
	 	ADD A, #30H 
	 	ACALL SEND_MOD 
	 	SJMP RETT 
	 	NOT_YET: MOV A, R6 
	 	MOV B, #10 
	 	DIV AB 
	 	ADD A, #30H 
	 	ACALL SEND_MOD 
	 	MOV A, B 
	 	ADD A, #30H 
	 	ACALL SEND_MOD 
RETT: RET 
;*************************************** 
SEND_MOD: 
	 	ACALL SENDD 
	 	SEND_AG: ACALL RECC 
	 	CJNE A, #'@', SEND_AG 	 	 
RET 
REC_MOD: 
	 	ACALL RECC 
	 	MOV R6, A 
	 	MOV A, #'@' 
	 	ACALL SENDD 
	 	ACALL SDELAY 
	 	MOV A, R6 
	 	CJNE A, #'$', REC_RET 
	 	LJMP MAIN_STR 	 
REC_RET: RET 
;***************************************
SERIAL_INT: 
 	MOV TMOD,#00100000B  	 ;timer1 mod2
	MOV TH1,#-12             ;boad rate=2400BPS
	 	MOV SCON, #01010000B    
	 	SETB TR1 
RET 
SENDD: 
	 	MOV SBUF, A 
	 	HERE: JNB TI, HERE 
	 	CLR TI 
RET 
RECC: 
	 	HERE1: JNB RI, HERE1 
	 	MOV A, SBUF 
	 	CLR RI 
	 	RET 	 
RET 
;*****************************
SDELAY: 
   MOV R0, #55 
   H1: MOV R1, #7 
   H2: DJNZ R1, H2 
   DJNZ R0, H1 
RET 
;*************************************** 
ERROR: DB "ERROR !!", 00H 
 
END 
