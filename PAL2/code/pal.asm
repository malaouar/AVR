;******************************************************************************
;  PAL Video Display (40 character x 25 line monochrome text)		
;  8 bit parallel load with  busy handshake lines 			
;PORTC:    C0 = Sync, feeds 1000 Ohm (or 1,2k) resistor
;         C1 = input for DATA Ready signal from host (ouput of D flip-flop)
;         C5= output for clearing D flip-flop (Busy signal from AVR to host) 
;PORTB:    B3(MOSI)  = Video, feeds 330 Ohm (or 560) resistor 
;      ... both (C0 and B3) meet 75 ohms (or 100) to ground				
;PORTD:  Receive DATA/command from host
;ATmega8 at 16MHz: lfuse=0x3f ; hfuse=0xc0.
;******************************************************************************

.include  "m8def.inc"
;  Define Registers and Port Pins
;
.def  tmp	=	R22			; Status reg temp save
.def  VisLn	=  	R23			; display visible line 0 - 199
							; 25  lines X 8 lin per chr= 200
.def  line	=	R20			; line counter  (312)
.def  lineh =	R21			; hi byte of line counter
;==================
.def  inpt		=	R17			; store input data/command from host
.def  hpos		=	R25			; hor cursor pos  0-39
.def  vpos		=	R24			; vert cursor pos 0-24

;---------------------------------
;interrupt service vectors

.org $0000	
	rjmp 	RESET    			;reset vector

.org OC1Aaddr	
	rjmp 	TIM1_COMPA			;TIMER1_OCA vector

.org OC1Baddr	
	rjmp 	TIM1_COMPB			;TIMER1_OCB vector
;******************************************************************************
; Program Starts here on Reset
;******************************************************************************
RESET:  		

	ldi	r16,low(RAMEND)
	out	SPL,r16
  ldi	r16,high(RAMEND)
	out	SPH,r16
 ; SPI Initialisation:

  ldi r17, 0b00100100      		; Set  CLK and CS outputs
  out DDRB,r17



	sbi	ddrc, 0				; C0: sync pin
	sbi	ddrc, 5				; C5: output for clearing D flip-flop (Busy signal from AVR to host)
	;------------
	sbi		portc, 5    ; CLR High
	;--------------
	
           
  ldi r17, 0b01010000        		; Enable SPI, Master, msb first, 
						; set clock rate (SPR1=SPR0=0) pour vitesse max
  out SPCR,r17
  sbi SPSR,0				; SPI2X (bit0)=1 ==> double vitesse

; TIMER1 Initialisation:
		
	ldi  	r16, 0		
	out	TCCR1A, r16			;no pwm,		
	ldi     r16, HIGH(1024)			;1024 for 64us line: 1/16MHz=0,0625S, 1024x0,0625=64uS		
	out	OCR1AH, r16			; write H before L		
	ldi	r16, LOW(1024)		
	out     OCR1AL, r16					
		
	ldi 	r16, 0b10000000		
	out     MCUCR, r16             		;enable sleep idle mode		

	ldi	r16, 0x03			; 03DE hex = 990 dec (1024-990=34 cycles befor intrA occurs)	
	out     OCR1BH, r16
	ldi	r16, 0xDE        		; 
	out     OCR1BL, r16			; 

	ldi     r16, 0x18			; allow OCR1A & OCR1B IRQ's
	out     TIMSk, r16		

	ldi 	r16, 9		
	out 	TCCR1B, r16			;full speed, clear on match (cTC mode 4)

;******************************************************************************
; Initialize the Display SRAM
;******************************************************************************
; fill display SRAM with the Startup Banner 
	ldi		ZL, 0x00    ; set to start of Banner in Prog Mem
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
			

;******************************************************************************
; Initialize Program Variables
;******************************************************************************
	ldi		Visln, 0x00			; keeps track of font gen line (0-7)
	ldi		lineh, 0x00			;  line counter 1-312
	ldi		line, 0x00			;  ""
	
	ldi		YL, 0x60			;init y pointer
	ldi		YH, 0x00			; 
	
  	ldi  	r16, 0	
	out     TCNT1H, r16			; 
	out     TCNT1L, r16			; 

	ldi		r16, 0x1C			; clear timer 1 IRQ's
	out		TIFR, r16			; clear timer 1 IRQ's

	;--------------------------------
; Tell host we are ready (clear Flip-Flop):
	cbi		portc, 5    ; CLR Low
	nop
	nop
	sbi		portc, 5    ; CLR High
	SEI						; Ready to go - enable system IRQ's - GO!!!

;******************************************************************************
; Main Loop 
;******************************************************************************
Main:
	nop
	sbis	pinc, 1		; test host data input  
	rjmp	Main				; if no data wait
	in		inpt, pind			; if data ready get it 
	rcall	ProcChr				; process the host data
	
	; Tell host we are ready again
	cbi		portc, 5		; clear D Flip-Flop  
	sbi		portc, 5		; 	
	rjmp	Main				; repeat

;******************************************************************************
; IRQ Service Routines
;******************************************************************************
TIM1_COMPB:						; IRQ service for OCR1B 
  mov r2, XL  ;push XL  (push and pop 2 cycles , mov 1 cycle)
  mov r3, XH  ;push XH
  mov r4, ZL  ;push ZL
  mov r5, ZH  ;push ZH
  mov r6, r1  ;push r1
  mov r7, r0  ;push r0
  
	in		tmp, SREG			; save the status register
	sbi		portc, 0			; raise the sync pin (its low during VSYNC, else no effect)
	sei						; enable IRQ before we sleep so OCR1A can work
	sleep						; wait for TIM1_COMPA IRQ
	out		SREG, tmp			; restore the status register

  mov r0, r7     ;pop r0
  mov r1, r6     ;pop r1
  mov ZH, r5     ;pop ZH
  mov ZL, r4     ;pop ZL
  mov XH, r3     ;pop XH
  mov XL, r2     ;pop XL

	reti						; all done, go back to Main Prgm
	

TIM1_COMPA:						; IRQ service for OCR1A 
;******************************************************************************
; PAL Video Generation Code (16MHZ System Clock)
;******************************************************************************
	cbi		portc, 0			; drop the sync pin 

	inc		line				; inc line counters
	brne		suite
	inc		lineh
       	; hsync pulse is 73 clocks wide so do some line setup
suite:
	cpi		lineh, 0x00			; Are we above line 255?
	breq		LINETST				; no, goto  
	cpi		line, 0x39			; yes: are we at the line after 312 (313)?
	brne		BLANk				; no, wait for hsync end


	clr		lineh				; yes, reset line counters
	clr		line				;
VS:
	rjmp		EOL				; line 1 is a VSYNC line, 

LINETST:	
	cpi		line, 0x04			; no: are we in line 1-3 (VSYNC)
	brlo		VS				; yes, leave SYNC pin low and exit
	cpI		line, 0x37			; no, are we below the first display line (No 55)?
	brlo		BLANk				; yes, blank line, wait for hsync to end
	breq		FIRSTDISP			; are we on the first active line?
	cpI		line, 0xFF			; are we above line 255 (last visible line)?
	brlo		display				; no, get ready for active display line

BLANk:
	ldi		VisLn, 0xFF			; reset visible line pointer
	rjmp		WAITSYNCEND			; 

FIRSTDISP:
	ldi		VisLn, 0x00			;  first active line	

DISPLAY:
	; set the SRAM character pointer (X) to the start of the current line (chrln)

	ldi		XL, 0x28			; 40 chrs per line
	ldi		XH, 0x60			; offset to start of SRAM 
	mov		r16, VISln			; Get current display line
	lsr		R16				; divide by 8 
	lsr		r16				; 
	lsr		r16				; 
	mul		XL, r16				; multiply by chrs per line
	ldi		r16, 0x00				; 
	add		R0, XH				; add SRAM start offset to result
	adc		R1, r16				; 
	movw		XL, R0				; mov it to X reg
	; set Z to point to base of font row
	ldi		ZL, 0x00			; ZL=0, ASCII code will be added for each character
	mov 		ZH, Visln			; ZH= current display line 
	andi		ZH, 0x07			; do ZH MOD 8
	ori		ZH, 0x10			; add $1000 for offset to start of font table

WAITSYNCEND:                       			;  else wait sync pulse end
	in      	r16, TCNT1L			;  
	cpi    	 	r16, 0x50	               	; is it @80 ticks
	brlo    	WAITSYNCEND			; no, look again
	sbi		portc, 0			; yes, raise sync (73 ticks wide hsync pulse)
	cpi		VisLn, 0xFF			; are we on an active display line?
	brne		WVa				; yes, active display line, wait for start of visible area
	rjmp		EOL				; no, blank line, we're done

wva:
	in      	r16, TCNT1L        		; wait for start of visible area
	cpi		r16, 0xE0           		; (sets the left side of the display)
	brlo   		 wva

;BUILDSCREEN:
	ldi		r19, 40				; 40 chr per line
	sbi		ddrb, 3				; mosi output
nextchr:
	ld 		ZL, X+	;2			; move curr chr in ZL
	lpm 		r16, Z	;3			; get font byte for current chr on curr line
	out 		SPDR, r16 ;1			; send over SPI
	dec		r19	;1			; next chr
	breq		BIEN	;1			; r19=0? yes:  well done!! else continue
	nop			    			; 
 	nop						; wait for SPI
	nop
	nop
	nop			    			; 
 	nop						; 16 cycles
	nop
	nop
	rjmp 		nextchr 	;2			; out next character

BIEN:
	nop 			; wait last caracter
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	cbi		ddrb, 3				; mosi input

EOL:							; end of line, we're done

	inc		VisLn				; inc visible line counter

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
	push inpt    ; save r17
	andi inpt, 0xE0      ; clear low 5 bits
	cpi inpt, 0xE0 	  	; is it goto LINE_X command?
	breq SETROW          ; Yes, jump to LINE_X subroutine
	
	; No is it "goto COl_Y" command?
	pop inpt     ; restore r17 
	push inpt    ; save r17 again we need it later
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
  pop inpt     ; restore r17
 	mov		vpos, inpt			; save new vertical position
  andi r17, 0x1F      ; clear high 3 bits
  ldi r18, 0x28   ; 40 caracters per line
  mul inpt, r18    ; (Nr of wanted line) x 40 --> the result is stored in R1:R0 (look MUL instruction)
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
  pop   inpt        ; restore input (r17)
	andi	inpt, 0x3F			; mask lower 6 bits (get new hpos x)
	sub		YL, hpos			;  calculate value of Y in the start of the current Line
	sbci	YH, 0x00			; 0 needed to substarct with carry (16bit)
	mov		hpos, inpt			; update hpos to the new value
	ldi		inpt, 0x00			; 0 needed to add with carry (16bit)
	add		YL, hpos			; Add to x the new horizental position
	adc		YH, inpt			;	16 bit addition
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
	ldi		inpt, 0x20			; space
	st		-Y, inpt			; remove last chr put space instead (destructive BS)
del2:
	ret							; return to Main
;--------------------------
RETURN:
  ; my code:
  inc		vpos			;  new vertical position
  cpi		vpos, 0x19			; are we above line 24?
  breq	SCROLLUP			; yes, need to scroll up one line

  mov r17, vpos      ; 
  ldi r18, 0x28   ; 40 caracters per line
  mul r17, r18    ; (Nr of wanted line) x 40 --> the result is stored in R1:R0 (look MUL instruction)
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
	
	ldi		r17, 0x20			; " "  chracter	
ffloop:
	st 		Y+, r17				; save to SRAM			
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
	ld		inpt, Z+			; get line 2 
	st		Y+, inpt			; place in line 1
	cpi		ZL, 0x48
	brne	scup1
	cpi		ZH, 0x04			; at the end of VRAM?
	brne	scup1				; no, do again
	ldi		inpt, 0x20			; space
scup2:
	st		Y+, inpt			; fill last line with spaces
	cpi		YL, 0x48      ; we reach the last char? Y=0x448 = 1096 decimal?
	brne	scup2			; No, continue

	; Yes, point the last line
	 ; we have already here YH=0X04 
	ldi		YL, 0x20			; YH= 0x04, YL=0X20 --> Y= 0x420 = 1056 (start of last line)
	ldi		vpos, 0x18			; set to last line (24)
	ldi		hpos, 0x00			;  reset hpos

	ret
;----------------------
SCROLLDN:
	push	YL
	push	YH
	ldi		YL, 0x20			; end of line 23  Y= 0x420 (we start from 0)
	ldi		YH, 0x04			; 
	ldi		ZL, 0x48			; end of line 24	
	ldi		ZH, 0x04			; 
scdn1:
	ld		inpt, -Y			; get line 2 
	st		-Z, inpt			; place in line 1
	cpi		YL, 0x60
	brne	scdn1
	cpi		YH, 0x00			; at the end of disp RAM?
	brne	scdn1				; no, do again
	ldi		inpt, 0x20			; space
scdn2:
	st		-Z, inpt			; fill last line with spaces
	cpi		ZL, 0x60
	brne	scdn2
	cpi		ZH, 0x00			; at the end of disp RAM?
	brne	scdn2				; no, do again
	pop		YH
	pop		YL
	ret


	
;******************************************************************************
; include  Data tables
;******************************************************************************

.include "banner.inc"			; opening screen banner 0x600-0x7F3
.include "font.inc"			; disp PRIMARY font 0x800-0xBFF

