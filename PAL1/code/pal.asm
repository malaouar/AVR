;/******************************************************************/
;  PAL Video Display (39 character x 25 line monochrome text)		/
;  8 bit parallel load with latch and busy handshake lines 			/ 
;Outputs :
;PORTC:    C0 = Sync, feeds 1000 Ohm (or 1,2k) resistor
;PORTB:    B3(MOSI)  = Video, feeds 330 Ohm (or 560) resistor 
;      ... both meet 75 ohms (or 100) to ground						/ 
;/*****************************************************************/

.include  "m8def.inc"

;  Define Registers and Port Pins
.def  tmp	=	R22			; Status reg temp save
.def  VisLn	=  	R23			; display visible line 0 - 199
							; 25 chr lines X 8 lin per chr= 200
.def  line	=	R20			; line counter  (312)
.def  lineh 	=	R21		; hi byte of line counter
;---------------------------------------------------------
;interrupt service vectors

.org $0000	
	rjmp 	RESET    			;reset vector

.org OC1Aaddr	
	rjmp 	TIM1_COMPA			;TIMER1_OCA vector

.org OC1Baddr	
	rjmp 	TIM1_COMPB			;TIMER1_OCB vector
;----------------------------------------------
RESET:  		
	ldi	r16,low(RAMEND)
	out	SPL,r16
        ldi	r16,high(RAMEND)
	out	SPH,r16

; SPI Initialisation:
    ldi 	r17, 0b00100100      	; Set  CLK and CS outputs
    out 	DDRB,r17
	sbi		ddrc, 0					; C0 sync pin         
    ldi 	r17, 0b01010000        	; Enable SPI, Master, msb first, 
									; set clock rate (SPR1=SPR0=0) pour vitesse max
    out 	SPCR,r17
  	sbi 	SPSR,0					; SPI2X (bit0)=1 ==> double vitesse

; TIMER1 Initialisation:		
	ldi  	r16, 0		
	out		TCCR1A, r16				;no pwm,		
	ldi     r16, HIGH(1024)			;1024 for 64us line: 1/16MHz=0,0625S, 1024x0,0625=64uS		
	out		OCR1AH, r16				; write H before L		
	ldi		r16, LOW(1024)		
	out     OCR1AL, r16							
	ldi 	r16, 0b10000000		
	out     MCUCR, r16             	;enable sleep idle mode		
	ldi		r16, 0x03				; 03DE hex = 990 dec (1024-990=34 cycles befor intrA occurs)	
	out     OCR1BH, r16
	ldi		r16, 0xDE        		; 
	out     OCR1BL, r16				; 
	ldi     r16, 0x18				; allow OCR1A & OCR1B IRQ's
	out     TIMSk, r16		
	ldi 	r16, 9		
	out 	TCCR1B, r16				;full speed, clear on match (cTC mode 4)


;******************************************************************************
; Initialize the Display SRAM
;******************************************************************************
; fill display SRAM with the Startup Banner 
	ldi		ZL, 0x00
	ldi		ZH, 0x0C			; set to start of Banner in Prog Mem
	ldi		YL, 0x60
	ldi		YH, 0x00			; set to start of SRAM
	ldi		XL, 0xE8
	ldi		XH, 0x03			; set X to 1000
			
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
	ldi		YL, 0x60			;
	ldi		YH, 0x00			; init y pointer
	out     TCNT1H, r16		
	out     TCNT1L, r16			 
	ldi		r16, 0x1C			; clear timer 1 IRQ's
	out		TIFR, r16			; clear timer 1 IRQ's	 
	SEI							; Ready to go - enable system IRQ's - GO!!!
		
;******************************************************************************
; Main Loop 
;******************************************************************************
Main:
	nop		; your code here
	nop		; ..............
	rjmp	Main				; repeat

;******************************************************************************
; IRQ Service Routines
;******************************************************************************

TIM1_COMPB:						; IRQ service for OCR1B 
	in		tmp, SREG			; save the status register
	sbi		portc, 0			; raise the sync pin (its low during VSYNC, else no effect)
	sei							; enable IRQ before we sleep so OCR1A can work
	sleep						; wait for TIM1_COMPA IRQ
	out		SREG, tmp			; restore the status register
	reti						; all done, go back to Main Prgm

TIM1_COMPA:						; IRQ service for OCR1A 
;******************************************************************************
; PAL Video Generation Code (16MHZ System Clock)
;
;******************************************************************************
	cbi		portc, 0			; drop the sync pin (here timer = 12 ??)
	inc		line				; inc line counters
	brne	suite
	inc		lineh
    ; hsync pulse is 73 clocks wide so do some line setup until timer = 12+73=85
suite:
	cpi		lineh, 0x00			; Are we above line 255?
	breq	LINETST				; no, goto  
	cpi		line, 0x39			; yes: are we at the line after 312 (313)?
	brne	BLANk				; no, wait for hsync end
	clr		lineh				; yes, reset line counters
	clr		line				;
VS:
	rjmp	EOL					; line 1 is a VSYNC line, 

LINETST:	
	cpi		line, 0x04			; no: are we in line 1-3 (VSYNC)
	brlo	VS					; yes, leave SYNC pin low and exit
	cpI		line, 0x37			; no, are we below the first display line (No 55)?
	brlo	BLANk				; yes, blank line, wait for hsync to end
	breq	FIRSTDISP			; are we on the first active line?
	cpI		line, 0xFF			; are we above line 255 (last visible line)?
	brlo	display				; no, get ready for active display line

BLANk:

	ldi		VisLn, 0xFF			; reset visible line pointer
	rjmp	WAITSYNCEND		 

FIRSTDISP:
	ldi		VisLn, 0x00			;  first active line	


DISPLAY:
	; set the SRAM character pointer (X) to the start of the current line (chrln)
	ldi		XL, 0x28			; # chrs per line
	ldi		XH, 0x60			; offset to start of SRAM 
	mov		r16, VISln			; Get current display line
	lsr		R16					; divide by 8 
	lsr		r16					; 
	lsr		r16					; 
	mul		XL, r16				; multiply by chrs per line
	ldi		r16, 0x00				; 
	add		R0, XH				; add SRAM start offset to result
	adc		R1, r16				; 
	movw		XL, R0			; mov it to X reg
	; set Z to point to base of font row
	ldi		ZL, 0x00			; ZL=0, ASCII code will be added for each character
	mov 	ZH, Visln			; ZH= current display line 
	andi	ZH, 0x07			; do ZH MOD 8
	ori		ZH, 0x10			; add $1000 for offset to start of font table



WAITSYNCEND:                    ;  else wait sync pulse end
	in      r16, TCNT1L	  
	cpi    	r16, 0x50	        ; is it @80 ticks
	brlo    WAITSYNCEND			; no, look again
	sbi		portc, 0			; yes, raise sync (73 ticks wide hsync pulse)
	cpi		VisLn, 0xFF			; are we on an active display line?
	brne	WVa					; yes, active display line, wait for start of visible area
	rjmp	EOL					; no, blank line, we're done



wva:
	in      r16, TCNT1L        	; wait for start of visible area
	cpi		r16, 0xD3           ; (sets the left side of the display)
	brlo   	wva

;BUILDSCREEN:
	ldi		r19, 39				; 39 chr per line
	ld 		ZL, X+				; move curr chr in ZL
	lpm 	r16, Z				; get font byte for current chr on curr line
	sbi		ddrb, 3				; mosi output
nextchr:
	out 	SPDR, r16			; send over SPI
	dec		r19	;1				; next chr
	breq	BIEN	;1			; r19=0? yes:  well done!! else continue
	ld 		ZL, X+	;2			; move curr chr in ZL
	lpm 	r16, Z	;3			; get font byte for current chr on curr line   
	nop			    			; 
 	nop							; wait for SPI
	nop
	nop
	nop			    			; 
 	nop							; 16 cycles
	nop
	nop
	nop

	rjmp 	nextchr 			; out next character

BIEN:
	nop 						; wait last caracter?????
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



;******************************************************************************
; include  Data tables
;******************************************************************************

.include "banner.inc"		; opening screen banner 0x600-0x7F3
.include "font.inc"			; disp PRIMARY font 0x800-0xBFF

