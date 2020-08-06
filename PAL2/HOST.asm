;*************************************************************
; program 
;portd,0 ---> Clck to flip-flop
; portd,6 ---> LED
;**************************************************************

.include "tn2313def.inc"


.org $0000		
	ldi 	r16, low(RAMEND)		
	out 	SPL, r16
	
						
	ldi     r16, 0b01000001        ;set portd,0  and 6 to outputs: 0 --> Clck to flip-flop, 6 --> LED		
	out     DDRD, r16
	
	ldi     r16, 0xFF        ;set portb  to output: data	
	out     DDRB, r16	

	;----------------
	cbi PORTD, 0	;  Clk Low
	
	
	sbi PORTD, 6	;  LED ON
	rcall delay2
	cbi PORTD, 6	;  LED OFF
	;rcall delay2
	;sbi PORTD, 6	;  
	;rcall delay2
	;cbi PORTD, 6	;  
 
;*********************************

	ldi     r16, 0xA5        ;clear screen	
	out     PORTB, r16
	rcall CLCK   ; send to TV

	; wait a moment
  rcall delay2

; goto line 3:
	ldi     r16, 0xE3        ;
	out     PORTB, r16
	rcall CLCK   ; send to TV


; Disply some texte
  ldi     r16, 'L'        ;L
	out     PORTB, r16
	rcall CLCK   ; send to TV
  ldi     r16, 'A'        ;A
	out     PORTB, r16
	rcall CLCK   ; send to TV
  ldi     r16, 'O'       ;O
	out     PORTB, r16
	rcall CLCK   ; send to TV
  ldi     r16, 'U'        ;U
	out     PORTB, r16
	rcall CLCK   ; send to TV
  ldi     r16, 'A'       ;A
	out     PORTB, r16
	rcall CLCK   ; send to TV
  ldi     r16, 'R'        ;R
	out     PORTB, r16
	rcall CLCK   ; send to TV

	

Fin:
	rjmp Fin

;****************
CLCK:
	sbi PORTD, 0	; set Clok high
	nop
	nop
	cbi PORTD, 0	; set Clok low
	;ret

;**************
Ready:
	sbic	pind, 1		; TV ready (pind, 1 low)?
	rjmp Ready  			; No then wait
	ret 		; Yes return
;*****************


delay:
	clr	r2
	LCD_delay_outer:
	clr	r3
	LCD_delay_inner:
	dec	r3
	brne	LCD_delay_inner
	dec	r2
	brne	LCD_delay_outer
ret


delay2:
  ldi r20, 10
wait:
  rcall delay
  dec r20
  brne wait
ret
