// blink a LED connected to any pin of PORTB on any AVR
// usefull for testing
// choose the mcu and frequency from the project --> config options  menu in AVRstudio

#include <avr/io.h>
#include <util/delay.h>

int main (void){
  //set PORTB for output
  DDRB = 0xFF;
  
  while (1){
	PORTB = 0xFF;  		//set PORTB  high
	_delay_ms(1000);
    PORTB =0;  			//set PORTB  low
    _delay_ms(1000);
  }

 return 1;
}
