PAL video generator 

ATmega8 @ 16MHz: lfuse=0x3f ; hfuse=0xc0.

  PORTC:  C0 = Sync, feeds 1000 Ohm (or 1,2k) resistor
  PORTB:    B3(MOSI)  = Video, feeds 330 Ohm (or 560) resistor 
       ... both (C0 and B3) meet 75 ohms (or 100) to ground					/ 
  
