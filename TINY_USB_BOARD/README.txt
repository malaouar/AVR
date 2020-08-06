
http://matrixstorm.com/avr/tinyusbboard/oldindex.html
http://matrixstorm.com/avr/tinyusbboard/

 A poorman's arduino.
 ATmega8 at 16MHz: lfuse=0x3f ; hfuse=0xc0.
 burn the given bootloader.hex using ur favorite programmer.
 u can build it on a prototyping board for easy testing your projects
 Be carefull if u need to use PD2, PD6 or PD7 in ur project.
 
 On some computers you can omit 68 Ohm resistors and 3.3V zeners. Resistor 1.5K is mandatory.
 I use this configuration (without 68 Ohm resistors and zeners) on a Toshiba laptop for many years without any problem !!!
  

- To put the board in programming mode, push the prog button (connect PD6 to GND) and power the board (or hit the reset button).  The board will be like a USBasp programmer.

we can  program it with avrdude or via the ARDUINO IDE (add it to boards.txt).

the first time when the ATMEGA8 is blank (after burning the bootloader) no need to push the prog button.

- Once programmed if we don't push the prog button our program starts automatically. Even plugged to a USB port. 

- ATTENTION: after programming the program don't start, we must reset the board (WITHOUT pushing the prog button) to start the program. 

