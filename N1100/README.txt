
Test of NOKIA 1100 LCD with ATMEGA8 3,3V powered
internal RC oscillator 8MHz:
    LF = C4
    HF = D9
=================== HARDWARE   =====================
connect SCE to GND
we use only 3 pins: RES, sdin, sclk !!

connect LCD on PORTB:
 PB2  --->  CLK  
 PB1  --->  DATA
 PB0  --->  RESET 
 
 Connect pins 1, 2 and 3 of LCD to +3.3V 
 Connect pins 6 and 7 of LCD to  GND
 
 ===================  SOFTWARE  ====================

- Font table in flash memory.
- draw image bitmap from flash memory.
- Normal mode (black on white) or invert mode.
- clear a given line or the current line.
 


