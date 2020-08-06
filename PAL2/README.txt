PAL video generator to interface with a microcontroller.
ATmega8 @ 16MHz: lfuse=0x3f ; hfuse=0xc0.

  PORTC:  C0 = Sync, feeds 1000 Ohm (or 1,2k) resistor
          C1 = input for DATA Ready signal from host (ouput of D flip-flop)
          C5= output for clearing D flip-flop (Busy signal from generator to host) 
  PORTB:    B3(MOSI)  = Video, feeds 330 Ohm (or 560) resistor 
       ... both (C0 and B3) meet 75 ohms (or 100) to ground					/ 
  PORTD:  Received DATA/command from host
  
7474:
  - Pin1 (CLR) --> C5 (ATMEGA8)
  - Pin3 (CLK) --> HOST 
  - Pin5 (Q) --> Both C1 (ATMEGA8) + HOST 
  - Pin2 (D) and Pin4 (PRE) --> +5V
  
 When the HOST wants to send Data/Command to VGA adaptor it puts the byte on PORTA and sets CLK High --> Q = H, then ATMEGA8 can read the sent byte.
 When ATMEGA8 finishes processing Data/Command it pulls CLR down  --> Q= L then HOST can send new Data/Command.
 
;******************************************************
; input data/commands:
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

Host controller:
ATTINY2313 (internal RC default):
    portd,0 ---> Clck to flip-flop (Data/Command Ready from host to generator)
    PORTB: to send data/command to generator
    portd,1:  input TV Ready  ( ouput of D flip-flop)