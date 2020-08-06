;*********************************
; VGA GENERATOR
; display  a Startup Banner from Flash
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
; we don't use rjmp cause it needs 2 cycles !!


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
//Blank video: 2 cycles
	cbi		ddrb, 3				; mosi input
	
; Increment sub character counter
  inc v_subchar_indx

	; increment VGA line counter
	movw r24, r10   ;1C copy r11:r10 to r25:r24
	adiw r24, 1 	;2C  inc r25: r24
	movw r10, r24    ;1C  copy   r25:r24 to r11:r10

;-----------------------------------
; restore X, Z ... registers  
  movw  XL, r2 ; copy   r3:r2 to  XH:XL
  movw  ZL, r4  ; copy  r5:r4 to  ZH:ZL

    RETI

;***************************************************************
;*  Reset Handler Routine
;***************************************************************
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

/* the compare value for going in sleep mode waiting for HSync (next line) */
    ldi r16, 61   ; 16 cycles befor HSync
    clr r17   ; r17=0
    out OCR1BH , r17
    out OCR1BL , r16


/*  the compare value for width of Hsync pulse */
; Pulse starts (falling edge) when T1 reach the TOP value
; pule finished (rising edge) when compare mach occurs
    ldi r16, 7  ; 7x8x62,5ns= 3,5us (prescaler=8,   clk cycle= 1/16Mhz=62,5ns)
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
	
	; Tell host we are ready again
	cbi		portc, 5		; clear D Flip-Flop  
	sbi		portc, 5		; 

	;-----------
	rcall	ProcChr				; process the host data/command

    rjmp MAIN
    
    
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

;******************************************************
; ProcChr - decode host cmd and update disp
; input commands:
; - 000  xxxxx  (input < 0x20) :
;    0x08  Back space 
;    0x0D  return
;    0x05  CLS 
;    0x0A  LineFeed 
;    0x01  SCROLLUP
;    0x02  SCROLLDN
;    other values are free to use
; - 0 01xxxxx to 0 1111111  ASCII chars
; - 10  xxxxxx  --> Goto clumn X
; - 110 xxxxx   free to use
; - 111 yyyyy   --> Goto line Y
;*************************************************************************************
ProcChr: 
	cpi		inpt, 0x80			;  is it a lower 128 code (ascii)? inpt <= 0x7F
	brlo	Is_ASCII				; yes,is it ASCII char or a command? (we can use BRCS instruction)
	; Else,  inpt >= 0x80
	;  is it "goto LINE_X" command?
	push inpt    ; save 
	andi inpt, 0xE0      ; clear low 5 bits
	cpi inpt, 0xE0 	  	; is it goto LINE_X command?
	breq SETROW          ; Yes, jump to LINE_X subroutine
	
	; No is it "goto COl_Y" command?
	pop inpt     ; restore  
	push inpt    ; save  again we need it later
	andi inpt, 0xC0      ; clear low 6 bits
	cpi inpt, 0x80 		; is it goto COl_Y command?
	breq SETCOL          ; Yes, jump to COl_Y subroutine
	pop inpt           ; No, restore from  stack (to avoid overflow) 
	ret                 

Is_ASCII:
  cpi inpt, ' '  ; is it < 0x20 (space)
  brlo  W_Cmd     ; Yes, then wich command? (we can use BRCS instruction)
  rjmp   ASCII    ; No, it's an ASCII char print it.
  
W_Cmd:
  cpi inpt, 0x08   ; is it a Back space ?
  breq  BACKSPACE
  cpi inpt, 0x0D   ; is it a carier return ?
  breq  RETURN
  cpi inpt, 0x05   ; is it a CLS ?
  breq  CLrS1  
  cpi inpt, 0x0A   ; is it a LineFeed ?
  breq  LINEFEED
  cpi inpt, 0x01   ; is it a SCROLLUP ?
  breq  SCROLLUP1
  cpi inpt, 0x02   ; is it a SCROLLDN ?
  breq  SCROLLDN1
  
  ret    ; any of this commands then return
;----------------
; cause I've got an "error: Relative branch out of reach"
; I added this lines
SCROLLUP1:
	rjmp SCROLLUP
SCROLLDN1:
	rjmp SCROLLDN
CLrS1:
	rjmp CLrS
;---------------------------------
; Goto Line y (y = 0 to 24):
SETROW:
; This is my code
 ; to go to LINE Nr X then: YH:YL= X*40 + 0x60
  pop inpt     ; restore 
 	mov		vpos, inpt			; save new vertical position
  andi inpt, 0x1F      ; clear high 3 bits
  ldi r16, 0x28   ; 40 caracters per line
  mul inpt, r16    ; (Nr of wanted line) x 40 --> the result is stored in R1:R0 (look MUL instruction)
  ldi		YL, 0x60    ; set to start of SRAM
  ldi		YH, 0x00	
	; Add r1:r0 to YH:YL
  add YL, r0     ; Add low byte
  adc YH, r1		 ; Add with carry high byte
  clr hpos       ; hpos = 0
  ret
;-----------------------------------------  
;Goto COlumn x ( x = 0 to 39):
;  Y at any position =  0x0060 + Line*0x28  + hpos
; Value of Y in the begening of any Line = (0x0060 + Line*0x28  + hpos) - hpos
; if we want to go to column 'x' then Y=   [(0x0060 + Line*0x28  + hpos) - hpos] + x
SETCOL:
  pop   inpt        ; restore input 
	andi	inpt, 0x3F			; mask lower 6 bits (get new hpos x)
	sub		YL, hpos			;  calculate value of Y in the start of the current Line
	sbci	YH, 0x00			; 0 needed to substarct with carry (16bit)
	mov		hpos, inpt			; update hpos to the new value
	ldi		r16, 0x00			; 0 needed to add with carry (16bit)
	add		YL, hpos			; Add to x the new horizental position
	adc		YH, r16			;	16 bit addition
	ret
;-----------------------------------------
BACKSPACE:
	cpi		hpos, 0x00			; are we already at the left edge?
	brne	del1				; no, move left one chr
	cpi		vpos, 0x00			; are we already on the top line?
	breq	del2  				; yes, nothing to do, so end
	dec		vpos				; no, move up one line
	ldi		hpos, 0x28			; & set the cursor to the right-most chr (+1 for next instruction)
del1:	
	dec		hpos				; move cursor left one char
	ldi		r16, 0x20			; space
	st		-Y, r16			; remove last chr put space instead (destructive BS)
del2:
	ret							; return to Main
;--------------------------
RETURN:
  ; my code:
  inc		vpos			;  new vertical position
  cpi		vpos, 0x19			; are we above line 24?
  breq	SCROLLUP			; yes, need to scroll up one line

  mov r16, vpos      ; 
  ldi r21, 0x28   ; 40 caracters per line
  mul r16, r21    ; (Nr of wanted line) x 40 --> the result is stored in R1:R0 (look MUL instruction)
  ldi		YL, 0x60    ; set to start of SRAM
  ldi		YH, 0x00	
	; Add r1:r0 to YH:YL
  add YL, r0     ; Add low byte
  adc YH, r1		 ; Add with carry high byte
  clr hpos		; hpos=0
  ret
  

;------------------------------
LINEFEED:
	cpi		vpos, 0x18			; are we at line 24?
	breq	SCROLLUP			; yes, need to scroll up one line
	inc		vpos				; no, move cursor down 1 line
	adiw	YL, 0x28			; adjust Y pointer
	ret							; return to Main
 
;---------------------------------------------
ASCII:
	st		Y+, inpt			; store chr
	inc		hpos				; inc hpos
	cpi		hpos, 0x28			; past eol?
	brne	wrap1				; No, return
	ldi		hpos, 0x00			; Yes, reset hpos
	inc		vpos				; inc v pos
	cpi		vpos, 0x19			; is it below last line (25)?
	brne	wrap1				; Yes,  exit
	rjmp	scrollup	      ; and scroll screen up
wrap1:
	ret	

;------------------------------- 
; Clear the Screen 
CLrS:
 	ldi		YL, 0x60    ; set to start of SRAM
	ldi		YH, 0x00			

	ldi		XL, low(1000)    ; set X to 1000
	ldi		XH, high(1000)			
	
	ldi		r16, 0x20			; " "  chracter	
ffloop:
	st 		Y+, r16				; save to SRAM			
	sbiw		XL, 1				; dec X
	brne		ffloop				; do until X=0
 	ldi		YL, 0x60    ; set to start of SRAM
	ldi		YH, 0x00	
	clr		hpos 			  ; set cursor to top left pos (0 , 0)
	clr		vpos 			  ; 
			
  ret

;-------------------------------
SCROLLUP:
	ldi		YL, 0x60			; start of first line Y= 0x0060 = 96 decimal
	ldi		YH, 0x00			; 
	ldi		ZL, 0x88			; start of second line		
	ldi		ZH, 0x00			; 
scup1:
	ld		r16, Z+			; get line 2 
	st		Y+, r16			; place in line 1
	cpi		ZL, 0x48
	brne	scup1
	cpi		ZH, 0x04			; at the end of VRAM?
	brne	scup1				; no, do again
	ldi		r16, 0x20			; space
scup2:
	st		Y+, r16			; fill last line with spaces
	cpi		YL, 0x48      ; we reach the last char? Y=0x448 = 1096 decimal?
	brne	scup2			; No, continue

	; Yes, point the last line
	 ; we have already here YH=0X04 
	ldi		YL, 0x20			; YH= 0x04, YL=0X20 --> Y= 0x420 = 1056 (start of last line)
	ldi		vpos, 0x18			; set to last line (24)
	ldi		hpos, 0x00			;  reset hpos

	ret
;-------
SCROLLDN:
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
