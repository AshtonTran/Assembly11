;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F690. This file contains the basic code               *
;   building blocks to build upon.                                    *  
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	   Ashton Tran                                        *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P16F690.INC                                      *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


	list		p=16f690		; list directive to define processor
	#include	<P16F690.inc>		; processor specific variable definitions
	
	__CONFIG    _CP_OFF & _CPD_OFF & _BOR_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF


; '__CONFIG' directive is used to embed configuration data within .asm file.
; The labels following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.

;***** VARIABLE DEFINITIONS


w_temp		 EQU	0x7D			; variable used for context saving
status_temp	 EQU	0x7E			; variable used for context saving
pclath_temp	 EQU	0x7F			; variable used for context saving


setinal      EQU    0X23 
portc        EQU    0x24            
State        EQU    0x25
portb		 EQU    0x26				
COUNT        EQU    0x27

;**********************************************************************
	ORG	    	0x000			; processor reset vector
  	goto		main			; go to beginning of program


	ORG	    	0x004			; interrupt vector location
	movwf		w_temp			; save off current W register contents
	movf		STATUS,w		; move status register into W register
	movwf		status_temp		; save off contents of STATUS register
	movf		PCLATH,w		; move pclath register into W register
	movwf		pclath_temp		; save off contents of PCLATH register


; isr code can go here or be located as a call subroutine elsewhere

	nop

	BSF			setinal,0
	BCF			PIR1,TMR1IF
	MOVLW		0x83				;0x3C 131
	MOVWF		TMR1H
	MOVLW		0xAF 				;175
	MOVWF		TMR1L
		
	INCF        COUNT               
	

	movf		pclath_temp,w		; retrieve copy of PCLATH register
	movwf		PCLATH		    	; restore pre-isr PCLATH register contents	
	movf		status_temp,w		; retrieve copy of STATUS register
	movwf		STATUS			    ; restore pre-isr STATUS register contents
	swapf		w_temp,f
	swapf		w_temp,w	     	; restore pre-isr W register contents
	retfie				        	; return from interrupt

main

	BANKSEL   	INTCON
	MOVLW     	xC0            ; Place 10100000 into INTCON  - Set the Timer0 Overflow Interupt and enables GIE
	MOVWF     	INTCON 	
	BANKSEL   	T1CON
	MOVLW    	0x31			;0x11 0x31 0x25 Look up TIM1 comfiguration 0x11 = 0001 0001 (bit zero enables TMR1, bit 4 and 5 Prescaler Preload)
	MOVWF    	T1CON
	BANKSEL  	PIR1	
	CLRF     	PIR1
	BANKSEL   	PIE1
	MOVLW    	0x01
	MOVWF    	PIE1
	BANKSEL   	PIR1
	BCF       	PIR1,TMR1IF
	MOVLW       0x3C                ; Testing Values For Closer Time Original 0x0B 00 
	MOVWF       TMR1H	            ; TMR1 High Byte
	MOVLW       0xAF               ; Testing Values For Closer Time Original 0xBD BF
	MOVWF       TMR1L 


	BANKSEL 	ANSEL   	 
	CLRF    	ANSEL        
	BANKSEL 	ANSELH
	CLRF		ANSELH	     
	BANKSEL 	TRISB	
	CLRF    	TRISB
	BANKSEL 	TRISC	     
	CLRF    	TRISC	     ;Make Port C an output only
	BANKSEL 	PORTC        ;
    CLRF    	PORTC       
	MOVLW   	D'1'         ; Place Value in State
    MOVWF   	State




Main_Loop_Start

	BTFSS 		setinal,0

	goto  		Main_Loop_Start
	BCF   		setinal,0	

	BTFSS 		COUNT,2
	goto  		Main_Loop_Start	
					;		State Machine increment from 0 to 8

							;		State Machine Steering
	CLRF  		COUNT

SM_Steering
		
		  	   
	    movf	State,w
		xorlw	D'1'
		btfsc	STATUS,Z
		goto	SM_State1
		banksel State
		movf	State,w
		xorlw	D'2'
		btfsc	STATUS,Z
		goto	SM_State2
		movf	State,w
		xorlw	D'3'
		btfsc	STATUS,Z
		goto	SM_State3
		movf	State,w
		xorlw	D'4'
		btfsc	STATUS,Z
		goto	SM_State4
		movf	State,w
		xorlw	D'5'
		btfsc	STATUS,Z
		goto	SM_State5
		movf	State,w
		xorlw	D'6'
		btfsc	STATUS,Z
		goto	SM_State6
		movf	State,w
		xorlw	D'7'
		btfsc	STATUS,Z
		goto	SM_State7
		movf	State,w
		xorlw	D'8'
		btfsc	STATUS,Z
		goto	SM_State8
		movf	State,w
		xorlw	D'9'
		btfsc	STATUS,Z
		goto	SM_State9
		movf	State,w
		xorlw	D'10'
		btfsc	STATUS,Z
		goto	SM_State10
				

	goto SM_Steering
;*************************************************************************
;		End of State Machine Steering
;*************************************************************************



;*************************************************************************
;		State Machine State 0 
;       output (0x80 to port c) to the ligth bar
;*************************************************************************

SM_State1  
	clrf    PORTB
	banksel PORTC
	movlw   0x80
    movwf   portc
	movf    portc,W
	movwf	PORTC
 	movlw   D'2'
	movwf	State	
;	goto	SM_State1			;Go to next State	
	goto SM_Exit
;*************************************************************************
;		State Machine State 1
;       output (0x40 to portc ) to the ligth bar
;*************************************************************************
SM_State2
	banksel PORTC
	movlw   0x40
	movwf   portc
	movf    portc,W
	movwf   PORTC
	movlw   D'3'
	movwf	State  
;	goto	SM_State2				;Go to next State		
	goto SM_Exit

;*************************************************************************
;		End of State Machine State 1
;*************************************************************************
;*************************************************************************
;		State Machine State 2
;       output (0x20) to the ligth bar
;*************************************************************************

SM_State3
	banksel PORTC
	movlw   0x20
	movwf   portc
	movf    portc,W
	movwf	PORTC
	movlw   D'4'
	movwf	State
;	goto	SM_State3				;Go to next State		
	goto SM_Exit

;*************************************************************************
;		End of State Machine State 2
;*************************************************************************
;*************************************************************************
;		State Machine State 3
;   output a (0x10) to the ligth bar
;*************************************************************************

SM_State4
	banksel PORTC
	movlw   0x10
	movwf   portc
	movf    portc,W
	movwf	PORTC
	movlw   D'5'
	movwf	State 
;	goto	SM_State4				;Go to next State		
	goto SM_Exit

;*************************************************************************
;		End of State Machine State 3
;*************************************************************************	
;*************************************************************************
;		State Machine State 4
;       output a (0x08) to the ligth bar
;*************************************************************************

SM_State5
	banksel PORTC
	movlw	0x08
	movwf   portc
	movf    portc,W
	movwf	PORTC
 	movlw   D'6'
	movwf   State
;	goto	SM_State5				;Go to next State	
	goto SM_Exit
;*************************************************************************
;		End of State Machine State 4
;*************************************************************************	
;*************************************************************************
;	 	State Machine State 5
;        output a (0x04) to the ligth bar
;*************************************************************************

SM_State6
 	banksel PORTC
	movlw   0x04
	movwf   portc
	movf    portc,W
	movwf	PORTC
 	movlw   D'7'
	movwf   State
;	goto	SM_State6				   ;Go to next State
	goto SM_Exit

;*************************************************************************
;		End of State Machine State 5
;*************************************************************************	
;*************************************************************************
;		State Machine State 6
;        output a (0x02) to the ligth bar
;*************************************************************************

SM_State7
	banksel PORTC 	
	movlw	0x02
	movwf   portc
	movf    portc,W
	movwf	PORTC
	movlw   D'8'
	movwf	State
;	goto	SM_State7				;Exit State Machine	
	goto SM_Exit

;*************************************************************************
;		End of State Machine State 6
;*************************************************************************	

;*************************************************************************
;		State Machine State 8
;        output a (0x01) to the ligth bar
;*************************************************************************

SM_State8
	banksel PORTC
	movlw   0x01
	movwf   portc
	movf    portc,W
	movwf	PORTC
	movlw   D'9'
	movwf   State  
;	goto	SM_State0				;Exit State Machine	
	goto SM_Exit

;*************************************************************************
;		End of State Machine State 8
;*************************************************************************	

;*************************************************************************
;		State Machine State 9
;        output a (PORTB RB4) to the ligth bar
;*************************************************************************

SM_State9
	banksel PORTB
	clrf    PORTC
	movlw   0x20
	movwf   portb
	movf    portb,W
	movwf   PORTB
	movlw   D'10' 
	movwf   State
	goto    SM_Exit

;*************************************************************************
;		End of State Machine State 9
;*************************************************************************	

;*************************************************************************
;		State Machine State 10
;        output a (PORTB RB4) to the ligth bar
;*************************************************************************

SM_State10
	banksel PORTB
	clrf    PORTB
	movlw   0x10
	movwf   portb
	movf    portb,W
	movwf   PORTB
	movlw   D'1' 
	movwf   State
	goto    SM_Exit

;*************************************************************************
;		End of State Machine State 10
;*************************************************************************

SM_Exit	;		End Of State Machine 

goto Main_Loop_Start


	ORG	0x2100				; data EEPROM location
	DE	1,2,3,4				; define first four EEPROM locations as 1, 2, 3, and 4


	END     