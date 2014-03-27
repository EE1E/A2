; WRITTEN BY            AHMAD KHATTAB AND ROMAN MITCH
; DATE                  05/02/2014
; FILE SAVED AS         TEST.ASM
; DEVICE                PIC16F84
; OSCILLATOR            XT (4MHZ)
; WATCHDOG              DISABLED
; CODE PROTECT          OFF
; POWER-UP TIMER		ENABLED
; FUNCTION              TRAFFIC LIGHTS
; OUTPUTS ON PORT B: BUZZER=0, RED=1, AMBER=2, GREEN=3, PASSENGER RED=4, PASSENGER GREEN=5, 
; INPUTS ON PORT B:	 6+7 WILL BE THE BUTTONS ON BOTH SIDES OF THE ROAD
; PORT A OUTPUT: PIN0=WAIT LIGHT                   
;   
; -----------------------   GENERAL EQUATES    --------------------------------
RBIF	EQU		0X00
GIE		EQU		0X07
RBIE	EQU		0X03
; -----------------------   I/O EQUATES    --------------------------------
PORTB   EQU     0X06    ;ASSIGN THE PORTB REGISTER TO THE LABEL 'PORTB'
PORTA	EQU		0X05
; -----------------------   REGISTER EQUATES    --------------------------------
MCOUNT 	EQU 	0X0C
NCOUNT 	EQU 	0X0D
DEL_ARG	EQU		0X0E	;VARIABLE HOLDING ARGUMENT FOR DELAY FUNCTION
INTCON	EQU		0X0B
ACOUNT	EQU		0X12	;COUNTER FOR FLASHING AMBER LED
BCOUNT	EQU		0X13	;COUNTER FOR SWITCHING THE BUZZER
ACOUNT1	EQU		0X14

; ----------------------- MAIN PROGRAM ------------------------------------
        ORG     0X00    		;'ORG' SPECIFIES THE MEMORY LOCATION OF THE PROGRAM
		GOTO	START

		ORG	 	0X04
		GOTO	INT_SER

INT_SER							;INTERRUPT SERVICE ROUTINE
		BSF		PORTA,0			;TURN ON WAIT LIGHT
		MOVLW	0X15
		MOVWF	DEL_ARG
		CALL	DELAY			;WAIT 3 SECONDS
		
		MOVLW 	B'00010100'		;TURNS ON THE RED PEDESTIAN LED AND THE AMBER TRAFFIC LED 
		MOVWF	PORTB
		MOVLW	0X15
		MOVWF	DEL_ARG
		CALL	DELAY			;DELAY 3 SECONDS
		MOVLW 	B'00010010'		;TURNS ON THE RED PEDESTIAN LED AND THE RED TRAFFIC LED 
		MOVWF	PORTB
		MOVLW	0X15
		MOVWF	DEL_ARG
		CALL	DELAY			;DELAY 3 SECONDS
		BCF		PORTA,0			;TURNS OFF WAIT LIGHT
		MOVLW 	B'00100010' 	;TURNS ON THE GREEN PEDESTIAN LED AND THE RED TRAFFIC LED
		MOVWF	PORTB 
		CALL	BFLASH		
		CALL	AFLASH			;FLASHES AMBER LED AND PASSENGER GREEN AT THE SAME TIME
		CALL	AFLASH1			;KEEPS FLASHING AMBER WHILE PASSENGER LED = RED
		
		
		MOVLW 	B'00011000' 	;TURNS ON THE RED PEDESTIAN LED AND THE GREEN TRAFFIC LED (DEFAULT STATE)
		MOVWF	PORTB

		BCF 	INTCON,RBIF		;CLEAR INTERRUPT FLAG IN INTCON
				
		RETFIE
	


START	
		MOVLW   B'11000000' 	;WE HAVE TWO BUTTONS WHICH WILL GO TO IN 6 AND 7 THE REST OF PINS ARE OUTPUTS
        TRIS    PORTB   		;CONFIGURE PORTB WITH THE VALUE IN W (THE
                        		;WORKING REGISTER) 1=INPUT AND 0=OUTPUT.  
                        		;SO 00 (ALL 0'S) MAKES ALL PORTB LINES OUTPUTS.
        CLRF    PORTB   		;CLEAR THE PORTB REGISTER
		CLRF	PORTA
		MOVLW 	0X00
		TRIS	PORTA			;MAKE PORT A INTO OUTPUT		

		BSF		INTCON,GIE		;ENABLES THE INTERRUPT
		BSF		INTCON,RBIE
		MOVLW 	B'00011000' 	;TURNS ON THE RED PEDESTRIAN LED AND THE GREEN TRAFFIC LED (DEFAULT STATE)
		MOVWF	PORTB		
LOOP   	GOTO    LOOP



DELAY			
DSTART	MOVLW 	0XFF			;RUNS A DELAY  OF 255*255*3 MICRO SECONDS DEL_ARG TIMES
		MOVWF 	MCOUNT
GET_N	MOVLW 	0XFF
		MOVWF 	NCOUNT
DEC_N 	DECFSZ 	NCOUNT,F
		GOTO 	DEC_N
		DECFSZ 	MCOUNT,F
		GOTO 	GET_N
		DECFSZ	DEL_ARG,1
		GOTO	DSTART
		RETURN

BFLASH	MOVLW	0X14			;BUZZER RUNS 20 TIMES AND ACTS AS A DELAY OF 8 SECONDS
		MOVWF	BCOUNT
BSTART	MOVLW 	B'00100011' 	;TURNS ON THE RED PEDESTIAN LED AND THE GREEN TRAFFIC LED AND BUZZER
		MOVWF	PORTB
		MOVLW	0X01
		MOVWF	DEL_ARG
		CALL	DELAY			;DELAY 0.2 SECONDS
		MOVLW 	B'00100010' 	;TURNS OFF BUZZER ONLY
		MOVWF	PORTB 
		MOVLW	0X01
		MOVWF	DEL_ARG
		CALL 	DELAY			;DELAY 0.2 SECONDS
		DECFSZ	BCOUNT,1	
		GOTO	BSTART
		RETURN

AFLASH1	MOVLW	0X04			;FLASHES AMBER LED 4 TIMES AND ACTS AS A DELAY OF 3 SECONDS
		MOVWF	ACOUNT1
ASTART1	MOVLW 	B'00010100' 	;TURNS ON THE RED PEDESTIAN LED AND THE AMBER TRAFFIC LED 
		MOVWF	PORTB
		MOVLW	0X02
		MOVWF	DEL_ARG
		CALL	DELAY			;DELAY 0.4 SECONDS
		BCF 	PORTB,2			;TURNS OFF AMBER LED ONLY
		MOVLW	0X02	
		MOVWF	DEL_ARG
		CALL 	DELAY			;DELAY 0.4 SECONDS
		DECFSZ	ACOUNT1,1
		GOTO	ASTART1
		RETURN

AFLASH	MOVLW	0X05			;FLASHES THE AMBER LED AND PASSENGER GREEN LED AT THE SAME TIME AND BUZZER 10 TIMES ALSO ACTS AS A DELAY OF 4 SECONDS
		MOVWF	ACOUNT
ASTART	MOVLW 	B'00100101' 	;TURNS ON THE AMBER LED AND PASSENGER GREEN AND BUZZER
		MOVWF	PORTB 
		MOVLW	0X01
		MOVWF	DEL_ARG
		CALL	DELAY			;DELAY 0.2 SECONDS
		MOVLW 	B'00100100' 	;TURNS ON THE AMBER LED AND PASSENGER GREEN AND TURNS OFF BUZZER, ALLOWS THE BUZZER TO BEEP TWICE FOR ONE FLASH OF LEDS
		MOVWF	PORTB 
		MOVLW	0X01
		MOVWF	DEL_ARG
		CALL	DELAY			;DELAY 0.2 SECONDS
		CLRF	PORTB
		MOVLW 	B'00000001' 	;TURNS ON THE  BUZZER ONLY
		MOVWF	PORTB 
		MOVLW	0X01
		MOVWF	DEL_ARG
		CALL	DELAY			;DELAY 0.2 SECONDS
		MOVLW 	B'00000000' 	;TURNS OFF THE AMBER LED AND PASSENGER GREEN AND BUZZER
		MOVWF	PORTB 
		MOVLW	0X01
		MOVWF	DEL_ARG
		CALL	DELAY			;DELAY 0.2 SECONDS
	
		DECFSZ	ACOUNT,1
		GOTO	ASTART
		RETURN

        END
