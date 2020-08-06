//*****************************************************************************
// File Name	: 'lcd.c'
// Title	: 4 bit LCd interface
//*****************************************************************************
#include "lcd.h"


void LCD_Char(uint8_t ch)	{	//Sends Char to LCD

	LCDP=((ch&0b11110000)>>2);	// high nible
	LCDP|=1<<LCD_RS;		// RS high
	LCDP|=1<<LCD_E;		// E high	
	_delay_ms(1);
	LCDP&=~(1<<LCD_E);	// E low	
	_delay_ms(1);
	LCDP=((ch&0b00001111)<<2);  // low nible
	LCDP|=1<<LCD_RS;		// RS high
	LCDP|=1<<LCD_E;		// E high		
	_delay_ms(1);
	LCDP&=~(1<<LCD_E);	// E low
	LCDP&=~(1<<LCD_RS);	// RS low
	_delay_ms(4);
}
//======================================		
void LCD_Command(uint8_t cmd){	//Sends Command to LCD

	LCDP=((cmd&0b11110000)>>2);  // high nible
	LCDP|=1<<LCD_E;	// E high	
	_delay_ms(1);
	LCDP&=~(1<<LCD_E);	// E low
	_delay_ms(1);
	LCDP=((cmd&0b00001111)<<2);	// low nible
	LCDP|=1<<LCD_E;	// E high	
	_delay_ms(1);
	LCDP&=~(1<<LCD_E);	// E low
	_delay_ms(4);
}
//======================================		
void LCD_init(void){//Initializes LCD

  LCDDR = 0xFF; // LCD port output
	_delay_ms(15);

	LCDP=((0x20)>>2); 		//4 bit mode
	LCDP|=1<<LCD_E;		// Togle E
	_delay_ms(1);
	LCDP&=~(1<<LCD_E);
	_delay_ms(4);
	
	LCD_Command(0b00101000);  //0x28 : Function set, 4 wire, 2 lines, 5x7
	LCD_Command(0b00001100);  // 0x0C: Display on, no cursor, no blink
	LCD_Command(0b00000110);  // 0x06: Address increment, no scrolling
	LCD_Command(0x01); // Clears LCD
}	
//======================================		
void LCD_clr(void)				//Clears LCD
{
	LCD_Command(0x01); 
}

//======================================		
void print_str(const char *text){
  while (*text) // string ends with 0x00
  {
  LCD_Char(*text++); // auto-increment the array pointer
  }
}
