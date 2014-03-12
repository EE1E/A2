; WRITTEN BY            Roman Mitch
; DATE                  10/03/2014
; FILE SAVED AS         ********
; DEVICE                PIC16F84
; OSCILLATOR            XT (4MHZ)
; WATCHDOG              DISABLED
; CODE PROTECT          OFF
; FUNCTION              *********
; -----------------------   GENERAL EQUATES    ----------------------------
W       EQU     0
F       EQU     1
ICOUNT  EQU     0X0C
JCOUNT  EQU     0X0D
KCOUNT  EQU     0X0E
RBIE    EQU     0X03    
GIE     EQU     0X07
RBIF    EQU     0X00
FCOUNT  EQU     0X0F
FLIGHT  EQU     0X10
GREEN   EQU     0
AMBER   EQU     1
RED     EQU     2
P_GREEN EQU     3
P_RED   EQU     4
; ------------------   I/O AND REGISTER EQUATES   -------------------------

PORTB   EQU     0X06
PC      EQU     0X02
INTCON  EQU     0X0B
; ----------------------- MAIN PROGRAM ------------------------------------
        ORG     0X00
        GOTO    START
        ORG     0X04
        GOTO INT_SER

INT_SER
             CLRF    PORTB
             CALL    SEQ
             BCF     INTCON,RBIF
        RETFIE


START
        MOVLW   B'10000000'
        TRIS    PORTB
        CLRF    PORTB
        BSF     INTCON,GIE
        BSF     INTCON ,RBIE

MAIN    BSF     PORTB, GREEN
        BSF     PORTB, P_RED
        GOTO    MAIN

DELAY   MOVLW   0X05
        MOVWF   KCOUNT
GET_I   MOVLW   0XFF
        MOVWF   ICOUNT
GET_J   MOVLW   0XFF
        MOVWF   JCOUNT
DEC_J   DECFSZ  JCOUNT,F
        GOTO    DEC_J
        DECFSZ  ICOUNT,F
        GOTO    GET_J
        DECFSZ  KCOUNT,F
        GOTO    GET_I
        RETURN

SDELAY  MOVLW   0XFF
        MOVWF   ICOUNT
GET_X   MOVLW   0XFF
        MOVWF   JCOUNT
DEC_X   DECFSZ  JCOUNT,F
        GOTO    DEC_X
        DECFSZ  ICOUNT,F
        GOTO    GET_X
        RETURN

FLASH   MOVLW   0X08
        MOVWF   FCOUNT
        CLRW
GET_F   MOVF    FLIGHT,W
        MOVWF   PORTB
        CALL    SDELAY
        CLRF     PORTB
        CALL    SDELAY
        DECFSZ  FCOUNT,F
        GOTO    GET_F
        RETURN

SEQ     BCF    PORTB, GREEN
        BSF    PORTB, AMBER
        BSF    PORTB, P_RED
        CALL   DELAY
        CLRF   PORTB
        BSF    PORTB, RED
        BSF    PORTB, P_GREEN
        CALL    DELAY
        CALL    DELAY
        CLRF   PORTB
        MOVLW  B'00001010'
        MOVWF  FLIGHT
        CALL   FLASH
        RETURN

        END


