
#include <avr/io.h>
#include <avr/delay.h>
#include "lcd.h"

//=======================
void adc_init(){
	// ADC Enable and prescaler of 128 (@16 MHz => Fs= 125KHz)
  ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);
  ADMUX= 0xC0; //REFS1-REFS0 = 11 -> select 1.1 vref , ADLAR =0 -> right-adjust the result

   //ADMUX = (1<<REFS0);    // AREF = AVcc = 5V, ADLAR =0 -> right-adjust the result
}

//===============================================
//read ch n of internal a/d  10 bit unsigned 
unsigned int read_adc(uint8_t ch){ 

  ch &= 0x07;  // AND operation of channel (0~7)  with 7 (clear upper bits)
  ADMUX = (ADMUX & 0xF8)|ch; // clears the bottom 3 bits before ORing
  // start single convertion (write ’1' to ADSC)
  ADCSRA |= (1<<ADSC);
  // wait for conversion to complete (ADSC becomes ’0' again)
  while(ADCSRA & (1<<ADSC));

  return (ADC);
} 

//====================================
int main(void){
  float x;
  char t[10];
  volatile uint16_t anval; //analog Value
  
	LCD_init();//init LCD bit, dual line, cursor right
	LCD_clr();
	print_str("Hello ADC !!");
 
  adc_init();
  
  for(;;){
  LCD_Command(0xC0);
  anval = read_adc(5);      // read adc value at channel 5 (PC5)
  //x = (anval*5.0)/1024.0; // for ref = AVcc = 5V
  x = (anval*1.1)/1024.0; // for ref = internal 1.1V
  
  // convert the double value into an ASCII representation
  dtostrf(x, 3, 3, t); // first 3 -> minimum field width of the output string including the possible ’.’ 
                      // and the possible sign. second 3 -> digits after point
  print_str(t);
	_delay_ms(100);
  }

	return 0;
}


//====================================================================
void convert(uint8_t byte){  // convert a byte from HEX to ASCII and display it
   uint8_t y;
   
   static char const hexchars[16] = "0123456789ABCDEF" ; 
   y=((byte&0xF0)>>4);  // get high nible and shift it to right 4 times
   y=hexchars[y % 16];
   LCD_Char(y);
   y=(byte&0x0F);  // get low nible
   y=hexchars[y % 16];
   LCD_Char(y);
}
//=====================================================
void int_ascii(uint16_t nr){ //convert an int < 1000  to ascii
  
  char str1[5] = "";// empty 5bytes string
  char str2[2]; // to concate  with  str1
  str2[1] = 0; // NULL terminated string
  if(nr<100) goto dix;
  // convert Prog Nr to ascii 
  str2[0] = ((nr/100) + '0'); // centaines
  strcat(str1, str2); // append to str1
dix:
  str2[0] = (((nr%100)/10) + '0'); // dizaines
  strcat(str1, str2); // append to str1
  str2[0] = (((nr%100)%10) + '0'); // unites
  strcat(str1, str2); // append to str1
  
  print_str(str1);
}
