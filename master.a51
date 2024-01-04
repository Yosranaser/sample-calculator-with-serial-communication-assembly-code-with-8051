ORG 00H 
ACALL SERIAL_INT 
MOV P1,#0FFH 
ACALL LCD_INT 

 
;*********** -- "ENTRY STATE"  -- ****************** 
ENTRY: 
ACALL CLEAR 
MOV A, #'$' 
ACALL SEND_MOD 
MOV DPTR, #LOOK_UP_TABLE 
NOT_COMPAT: ACALL MAIN 
MOV R1, A 
CLR C 
SUBB A, #0AH 
JNC NOT_COMPAT 
MOV A, R1 
ACALL DISP1 
ACALL SEND_MOD 
 
NOT_COMPAT1: ACALL MAIN 
MOV R1, A 
CLR C 
SUBB A, #0EH 
JNC NOT_COMPAT1 
MOV A, R1 
CLR C 
SUBB A, #0AH 
JC NOT_COMPAT1 
MOV A, R1 
ACALL DISP1 
ACALL SEND_MOD 
 
NOT_COMPAT2: ACALL MAIN 
MOV R1, A 
CLR C 
SUBB A, #0AH 
JNC NOT_COMPAT2 
MOV A, R1 
ACALL DISP1 
ACALL SEND_MOD 
 
UNWANTED: ACALL MAIN 
CJNE A, #0EH, UNWANTED 
MOV A, #61 
ACALL LCD_DATA 
 
MAIN_STR: 
ACALL REC_MOD 
MOV A, R6 
CJNE A, #'$', MAIN_CON 
SJMP ALL_FINISHED 
MAIN_CON: MOV A, R6 
ACALL LCD_DATA 
SJMP MAIN_STR 
;*********** -- "FINISH" -- ****************** 
ALL_FINISHED: ACALL MAIN 
SJMP ALL_FINISHED 
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
REC_RET: RET 
;*************************************** 
SERIAL_INT: 
 	MOV TMOD,#00100000B  	
	MOV TH1,#-12 
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
;*********** -- "LONG PRESS" -- ****************** 
MAIN: 
N_1: MOV P1, #0F0H         
	 	 MOV A, P1
	 	 CJNE A, #0F0H , N_1 
;*********** -- "DEBOUNCING EFFECT" -- ****************** 
N_2: MOV P1, #0F0H 
	 	 MOV A, P1 
	 	 CJNE A, # 0F0H, N_3 
	 	 SJMP N_2 
N_3: ACALL LDELAY 
	 	 MOV P1, #0F0H 
	 	 MOV A, P1 
	 	 CJNE A, # 0F0H, N_4 
	 	 SJMP N_2 
;***************************** 
N_4:   MOV P1,#11111111B 
   C1: CLR P1.0                
	    	   JB P1.4, C2 
	 	   MOV A, #7 
	 	   RET 
   C2: JB P1.5, C3 
	 	   MOV A, #8 
	 	   RET 
   C3: JB P1.6, C4 
	 	   MOV A, #9 
	 	   RET 
   C4: JB P1.7, C5 
   MOV A, #0AH     
   RET 
   C5: SETB P1.0             
	    	   CLR P1.1      
 	   JB P1.4, C6  	   
	   MOV A, #4 
	 	   RET  
   C6: JB P1.5, C7 
	 	   MOV A, #5 
	 	   RET 
   C7: JB P1.6, C8 
	 	   MOV A, #6 
	 	   RET 
   C8: JB P1.7, C9 
	 	   MOV A, #0BH 
	 	   RET 
   C9: SETB P1.1 
	    	   CLR P1.2 
	 	   JB P1.4, C10 
	 	   MOV A, #1 
	 	   RET 
  C10: JB P1.5, C11 
	 	   MOV A, #2 
	 	   RET 
  C11: JB P1.6, C12 
	 	   MOV A, #3 
	 	   RET 
  C12: JB P1.7, C13 
	 	   MOV A, #0CH 
	 	   RET 
  C13: SETB P1.2 
	   	   CLR P1.3 
 	   JB P1.4, C14    
   
	 	   ACALL ENTRY 
  C14: JB P1.5, C15 
	 	   MOV A, #00H 
	 	   RET 
  C15: JB P1.6, C16 
	 	   MOV A, #0EH 
	 	   RET 
  C16: JB P1.7, NEXT 
	 	   MOV A, #0DH 
	 	   RET 
NEXT: LJMP MAIN ;***************************** 
CLEAR:  
	 	   MOV A, #02H 
	 	   ACALL LCD_CMD 
	 	   MOV A, #01H 
	 	   ACALL LCD_CMD 
	 	   MOV A, #80H 
	 	   ACALL LCD_CMD 
	 	   MOV A, #0FH 
	 	   ACALL LCD_CMD 
RET 
;***************************** 
PRINT:  
	 	MOV R6,A 
	 	CLR C 
	 	SUBB A, #10 
	 	JNC NOT_YET 
	 	MOV A, R6 
	 	ADD A, #30H 
	 	ACALL LCD_DATA 
SJMP RETT 
NOT_YET: MOV A, R6  	
MOV B, #10 
	 	DIV AB 
	 	ADD A, #30H 
	 	ACALL LCD_DATA 
	 	MOV A, B 
	 	ADD A, #30H 
	 	ACALL LCD_DATA 
RETT: RET 
;***************************** 
MESSAGE:  
AGAIN: MOV A, #0 
	 	   MOVC A, @A+DPTR 
	 	   JZ FINISH 
	 	   ACALL LCD_DATA 
	 	   INC DPTR 
	 	   SJMP AGAIN 
FINISH: RET ;***************************** 
DISP1:  
   MOVC A, @A+DPTR 
   ACALL LCD_DATA 
RET 
;***************************** 
LCD_INT: 
   MOV A, #38H 
   ACALL LCD_CMD 
   MOV A, #0CH 
   ACALL LCD_CMD 
   MOV A, #01H 
   ACALL LCD_CMD 
   MOV A, #06H 
   ACALL LCD_CMD 
   MOV A, #80H 
   ACALL LCD_CMD 
RET 
;***************************** 
LCD_CMD: 
   MOV P2, A 
   CLR P3.6 
   SETB P3.7 
   ACALL SDELAY 
   CLR P3.7 
   ACALL LDELAY 
RET 
;***************************** 
LCD_DATA: 
   MOV P2, A 
   SETB P3.6 
   SETB P3.7 
   ACALL SDELAY 
   CLR P3.7 
   ACALL LDELAY 
RET 
;***************************** 
WAITING: 
   MOV R6, #12 
   WAIT2: ACALL LDELAY 
   DJNZ R6, WAIT2 
RET 
;***************************** 
LDELAY: 
   MOV R0, #50 
   G1: MOV R1, #255 
   G2: NOP 
   NOP 
   DJNZ R1, G2 
   DJNZ R0, G1 
RET 
;***************************** 
SDELAY: 
   MOV R0, #55 
   H1: MOV R1, #7 
   H2: DJNZ R1, H2 
   DJNZ R0, H1 
RET 
;***************************** 

WELCOME: DB "WELCOME", 00H 
	LOOK_UP_TABLE: 
	 	DB '0'   ; 0 
	 	DB '1'   ; 1 
	 	DB '2'   ; 2 
	 	DB '3'   ; 3 
	 	DB '4'   ; 4 
	 	DB '5'   ; 5 
	 	DB '6'   ; 6 
	 	DB '7'   ; 7 
	 	DB '8'   ; 8 
	 	DB '9'   ; 9 
	 	DB '/'   ; A 
	 	DB 'x'   ; B 
	 	DB '-'   ; C 
	 	DB '+'   ; D 
	 	DB '='   ; E 
	 	DB 'F'   ; F 
 
END 
