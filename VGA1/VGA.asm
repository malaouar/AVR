;*********************************
; VGA GENERATOR
; display  a Startup Banner
; 25 text lignes of 40 chars
; each char in text lines is drawn with 13 VGA lignes
;*********************************
.include  "m8def.inc"
; lfuse=0x3f ; hfuse=0xc0; 16MHz
;***********************
#define line_L r10    ; Index to VGA Lines (0 - 425) 525
#define line_H r11
#define line_base_lo r12  ; index to charcaters in RAM  (starts at 0X0060)
#define line_base_hi r13

#define v_text_indx   r17   ; Index to text lignes   (0 -- 24) 25 lignes
#define v_subchar_indx  r18    ; index to number of VGA lines per character
#define hcount         r19    ; char per text line counter 
#define hvar            r20   ; Variable to store byte to display
#define  inpt		R21			; store input data/command from host and used as tmp reg
#define  hpos		R22			; hor cursor pos  0-39
#define  vpos		R23			; vert cursor pos 0-24


#define VSYNC_PIN 0   ; PB0
;=======================================
; interrupt vector table for atmega8
	.org 0x00

	rjmp 	RESET 				; Reset Handler
	reti 			; IRQ0 Handler
	reti 			; IRQ1 Handler
	reti 			; Timer2 Compare Handler
	reti 			; Timer2 Overflow Handler
	reti 			; Timer1 Capture Handler
	reti 			; Timer1 CompareA Handler
	rjmp	TIM1_CMB ; Timer1 CompareB Handler
;====================
;TIM1_OVF: Timer1 overflow Handler  :
; we don't use rjmp cause it needs 3 cycles !!


//If line number is less than 2..ensure VSync is low
    sbiw r24 , 0x0002   ;2C   sub 2 from r25:r24
    brsh continue            ;2C  if greater than or equal to 2 jump
    cbi PORTB , VSYNC_PIN		; VSync Low
EXIT1:
	; increment VGA line counter
	movw r24, r10   ; copy r11:r10 to r25:r24
	adiw r24, 1 	; inc r25: r24
	movw r10, r24    ; copy   r25:r24 to r11:r10

    RETI

;===========================================
; we have 4x6 font 
; 13 VGA lines per character (1+ 6x2) so for 25 text lines: 25x13 = 325 then we have 155 spare lines
; we add 77 lines  at top and 78 at bottom
continue:
//If  line number  is more than 2 turn VSync  high
	sbi PORTB , VSYNC_PIN  ;2C     VSync High
  ; and wait for line 35 +77 
	movw r24, r10  ;1C   copy r11:r10 to r25:r24
	LDI r16 , HIGH(35 + 77)  ;1C  we start from 0
	CPI r24 , LOW(35 + 77)		; 1C
	CPC r25 , r16			; 1C 
	brlo exit1   ;1C  if lower than 35 + 15 exit
	;------------------
//If VGA line number is less than (515 - 78) it's a visible line
	movw r24, r10  ; 1C copy r11:r10 to r25:r24
	LDI r16 , HIGH(515 - 78)  ;1C we start from 0
	CPI r24 , LOW(515 - 78)		; 1C
	CPC r25 , r16		; 1C 
	brlo VIDEO  ; lower ; 2C
  ; if greater than or equal  (515 - 78) first increment VGA line counter
	movw r24, r10   ; copy r11:r10 to r25:r24
	adiw r24, 1 	; inc r25: r24
	movw r10, r24    ; copy   r25:r24 to r11:r10

//and If line number is more than 525 clear line counter 
	LDI r16 , HIGH(525)		; we count from 0
	CPI r24 , LOW(525)
	CPC r25 , r16
	BRLO EXIT		; lower,  exit
	; else clear VGA line counter
	clr r10
	clr r11
	movw r24, r10	; copy r11:r10 to r25:r24
EXIT:
    RETI

;=======================
VIDEO:
;We are in visible aera (VGA line is Lower tahn 515 - 78),draw lines
  ;-----------------------------------------------------
; save X, Z ... registers here if used in main program
;push and pop need 2 cycles , so we use  movw (1 cycle)
  movw r2, XL  ; copy XH:XL to r3:r2
  movw r4, ZL  ; copy ZH:ZL to r5:r4

; font is 4x6
; 13 VGA lines per character (1 + 6x2) 
    cpi v_subchar_indx, 13 ;1C    Are we done with this raw of characters?
    brlo prepare   ;2C     No , lower than 32, prepare you
    clr v_subchar_indx     ; Yes, then start from begin of raw 

; Increment the number of text lines
    inc v_text_indx
    cpi v_text_indx, 25     ; 25 Vertical text Lines done?
    brne cont1        ; No
    clr v_text_indx   ; Yes, start from begin

; and Return character pointer to start of memory
    ldi r16, 0x60   ; Line counter points to 0x0060
    mov line_base_lo, r16
    clr line_base_hi 
    rjmp  prepare
  
cont1:
; New row, increment to next character row
; 40 characters per horizontal line
    ldi r16, 40
    add line_base_lo, r16
    clr r16
    adc line_base_hi, r16
;--------------------------------------------
prepare:
	ldi 	ZH, 0x05			; setup jump table page address (high byte)
	mov		ZL, v_subchar_indx			;  ZL = index
	ijmp						; jump to table based on Z

; Load Z pointer with high byte of Font table adress in Flash
; first line
ROW1:  
    ldi ZH, 0x10  ;1C  High byte of  0x800 * 2 
    rjmp ready	; 2C
; 2nd
ROW2:
    ldi ZH, 0x11  ; High byte of  0x880 * 2
    rjmp ready

ROW3:
    ldi ZH, 0x12  ; High byte of  0x900 * 2
    rjmp ready

ROW4:
    ldi ZH, 0x13  ; High byte of  0x990 * 2
    rjmp ready

ROW5:
    ldi ZH, 0x14  ; High byte of  0xA00 * 2
    rjmp ready

ROW6:
  ldi ZH, 0x15  ; High byte of  0xA80 * 2
  rjmp ready
  
; the blank area
ROW7:
	nop  ; to equalize with rjmp in previous lines
	nop
  ldi ZH, 0x16  ; High byte of  0xB00 * 2
 

ready:
  ; point to chars in RAM
  movw XL, line_base_lo  ;1C   copy  r15:r14 to XH:XL
; 40 horizontal characters,  2 characters per byte
    ldi hcount, 20; 1C 


; to avoid large white aera in left of screen,  Preload first byte to be drawn
	ld ZL, X+		; 2C 
	lpm hvar, Z		; 3C
	swap hvar		; 1C
	ld ZL, X+		; 2C
	lpm r16, Z		; 3C
 	or hvar, r16	; 1C

;--------------------------------------------
; wait for start of visible area
wva:
	in      	r16, TCNT1L        		
	cpi		r16, 13   ; (sets the left side of the display)
	brlo   		 wva      ; lower, then wait
;-----------------------------------------------------   
; Unblank Video
    sbi		ddrb, 3				; mosi output
;-------------------------------------------
;Main pixel writing loop, 17 cycles per iteration
pixel_loop:
    ; send 
    out SPDR, hvar   ; 1 cycle
	 
; prevent a write collision: 2cycles
; if u  add a shift after then delete one nop here
    nop
	nop

; load first character, 6 cycles
    ld ZL, X+
    lpm hvar, Z
    swap hvar
; second character. 6 cycles
    ld ZL, X+
    lpm r16, Z
    or hvar, r16   ; put the font of two chars in one byte !!
; next
    dec hcount  ; 40 chars sent? 1 cycle
    brne pixel_loop		; No, continue : 2 cycles
;----------------------------------------	
;Blank video: 2 cycles
	cbi		ddrb, 3				; mosi input
	
; Increment sub character counter
  inc v_subchar_indx

	; increment VGA line counter
	movw r24, r10   ;1C copy r11:r10 to r25:r24
	adiw r24, 1 	;2C  inc r25: r24
	movw r10, r24    ;1C  copy   r25:r24 to r11:r10

;-----------------------------------
; restore X, Z ... registers here 
  movw  XL, r2 ; copy   r3:r2 to  XH:XL
  movw  ZL, r4  ; copy  r5:r4 to  ZH:ZL

    RETI

;***************************************************************
;* Func: RESET
;* Desc: Reset Handler Routine
;***************************************************************
;Reset procedure
reset:		;Set the stack pointer to the top of RAM
	ldi	r16,low(RAMEND)
	out	SPL,r16
    ldi	r16,high(RAMEND)
	out	SPH,r16

;--------------
; D Flip-Flop control line
	sbi	ddrc, 5				; C5: output for clearing D flip-flop (Busy signal from AVR to host)
	sbi	portc, 5    ; set CLR High
;--------------

  ;SETUP:
//Mark DDRB as output will use this for HSNC (OC1A) , VSYNC(PB0)
  sbi DDRB,0   	; VSync
	sbi DDRB,1		; HSync  (OC1A)
	; and SPI pins must be outputs
	sbi DDRB,2		; SS
	sbi DDRB,5		; CLK
	; At the moment we keep MOSI as input
	
	
	
//Pull vsync and HSync high 
  sbi PORTB,0   	; VSync
	sbi PORTB,1		; HSync  (OC1A)
    
; SPI Initialisation:
  ldi r16, 0b01010000        		; Enable SPI, Master mode, msb first, 
  out SPCR,r16       ; and set clock rate (SPR1=SPR0=0) for max speed
  sbi SPSR,0				; SPI2X (bit0)=1 ==> double speed


//Set the timer 
    ldi r16,  0xC2
    out TCCR1A,r16   ; Set OC1A on Compare Match, clear OC1A at BOTTOM  (inverting mode)

    ldi r16, 0x1A  ; 
    out TCCR1B, r16 ; prescaler = 8,  WGM1(3:0)= 1110; 0x0E -->   ICR1 = TOP, OCR1 = pulse width (fast PWM mode No 14)

//Set the top and compare counts
/* the counter top value : 1 line time*/
    ldi r16, 63
    clr r17   ; r17=0
    out ICR1H , r17
    out ICR1L , r16

/* the compare value for going in sleep mode waiting for next line */
    ldi r16, 61   ; 16 cycles befor HSync
    clr r17   ; r17=0
    out OCR1BH , r17
    out OCR1BL , r16


/*  the compare value for generating Hsync pulse */
    ldi r16, 7  ; 
    ;clr r17    
    out OCR1AH , r17
    out OCR1AL , r16

//Enable Timer1 (output compare B)  match and overflow interrupts
    ;ldi r16 , (1 << OCIE1B) |  (1 << TOIE1) ; TIMSK bits 3=1 and 2=1
	ldi 	r16, 0b00001100	
    out TIMSK , r16

;enable sleep idle mode
	ldi 	r16, 0b10000000		
	out     MCUCR, r16             				

;====================
; fill display SRAM with the Startup Banner 

	ldi		ZL, 0x00    ; set to start of Banner in Prog Mem .ORG 0x600 * 2 = 0x0C00
	ldi		ZH, 0x0C			

	ldi		YL, 0x60    ; set to start of SRAM
	ldi		YH, 0x00			

	ldi		XL, low(1000)    ; set X to 1000= 25x40
	ldi		XH, high(1000)			
			
frloop:
	lpm		r16, Z+				; get boot image
	st 		Y+, r16				; save to SRAM			
	sbiw	XL, 1				; dec X
	brne	frloop				; do until X=0

;============================
; Init variables:
  clr v_text_indx
  clr v_subchar_indx

;  Init RAM Pointer
  ldi r16, 0x60
  mov line_base_lo, r16
  clr line_base_hi 

//Initialize VGA line counter
    clr line_L		 ;r10=0x00
    clr line_H 		;r11=0x00
    movw r24, r10  ; copy r11:r10 to r25:r24

	;--------------------------------
; Tell host we are ready (clear Flip-Flop):
	cbi		portc, 5    ; CLR Low
	sbi		portc, 5    ; CLR High

  ; Ready, lest's GO !!!!!!
    sei
;========================
; your functions here
MAIN:
    nop
	sbis	pinc, 1		; test host data input  
	rjmp	Main				; if no data wait
	in		inpt, pind			; if data ready get it 
	
	;-----------
	rcall	ProcChr				; process the host data/command

	; Tell host we are ready again
	cbi		portc, 5		; clear D Flip-Flop  
	sbi		portc, 5		; 
door:
    rjmp door ;MAIN
;=========================
; Timer1 CompareB Handler
TIM1_CMB: 
; save status register
  in r9, SREG  ;
  ; and the MPR, it's used in main prog and interrupt routine
  mov r6, r16

	; enable IRQ before we sleep so TOVF1 can work
	sei						
	sleep

	; restore registers
  	mov r16, r6
    out SREG, r9  ;
	reti

;================
ProcChr:
	ldi		YL, 0x60    ; set to start of SRAM
	ldi		YH, 0x00			

	ldi		XL, low(1000)    ; set X to 1000= 25x40
	ldi		XH, high(1000)	
			
	ldi r16, ' '		
cls_loop:
	st 		Y+, r16				; save to SRAM			
	sbiw	XL, 1				; dec X
	brne	cls_loop				; do until X=0
	

	ldi		YL, 0x60    ; set to start of SRAM
	ldi		YH, 0x00			

text_l:
	inc r16
	st 		Y+, r16				; save to SRAM			
	cpi r16, 0x7F				; dec X
	brne	text_l				; do until X=0
	ret


;==================
; each char is drawn using 13 VGA lines 
; jump to value to load in ZH: en fonction de la ligne courant du character
.org 0x500
	rjmp row7  ; line 0 blank line
	rjmp row1  ; lines 1 and  2 --> row1
	rjmp row1
	rjmp row2  ; lines 3 and  4 --> row2 ... etc
	rjmp row2
	rjmp row3
	rjmp row3
	rjmp row4
	rjmp row4
	rjmp row5
	rjmp row5
	rjmp row6
	rjmp row6


;=================================
; .org 0x600
.include "banner.inc"			; opening screen banner 0x600-0x7F3
.include "font.inc"
