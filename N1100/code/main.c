
#include <avr/sleep.h>

#include "pcf8814.h"
#include "random.h"
#include "image.h"


void main() {
// char ascii[10]; // for debugging

unsigned char gen_numbers[768]; // table to know already generated numbers 
unsigned char x, y;
unsigned char *table, byte;
uint16_t number, i, j=0;


  set_sleep_mode(SLEEP_MODE_PWR_DOWN); //deep sleep

  init_lcd();

  random_init(0xabcd); // initialize 16 bit seed
 
  setCursor(35, 2); print("HELLO");
  setCursor(20, 4); print("WORLD !!");

  _delay_ms(2000);

  // blink a moment
  for(i=0; i<10; i++){
  // invert : white on black
  setInverse();
  _delay_ms(500);
  setNormal();
  _delay_ms(500);
  }


  cls(); // clear screen
  
// draw image randomly
for(i=0; i<768; i++) gen_numbers[i] = 0; // clear the buffer for generated numbers

for(;;){

  for(;;){
    number = random()%768; // generate a random number between 0 and 767
    
    if ( gen_numbers[number] != '*'){ // we use '*' as a flag to indicate the number is already generated
        gen_numbers[number] = '*'; // save flag in buffer to say number is generated (don't repeat the same number)
        break;
      }
	}


	if (++j == 768) break; // quit while loop

// calculate x and y
	y = number / 96; // line  (reste de devision)
	x = number - y*96 ; // column

	table = (unsigned char*)&(sebseb[number]);
    byte = pgm_read_byte(table);           
    setCursor(x, y);
    send(1, byte);
	_delay_ms(10);
	}

  setCursor(55, 6);
  print("Laouar");

  setCursor(50, 7);
  print("mahmoud");


	while( 1) { // enter sleep mode 
	sleep_mode();//This macro automatically sets the sleep enable bit, goes to sleep, and clears the sleep enable bit.
	}

}

