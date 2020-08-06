//*****************************************************************************
//
// File Name	: 'lcd.h'
// Title	: 4 bit LCd interface header file
// LCD data on PORTC n control on PORTB
//*****************************************************************************
#ifndef LCD
#define LCD

#include <inttypes.h>
#include <avr/io.h>
#include <util/delay.h>


#define LCD_RS	0 	//define MCU pin connected to LCD RS
#define LCD_E	1	//define MCU pin connected to LCD E
//#define LCD_D4	2	//define MCU pin connected to LCD D4
//#define LCD_D5	3	//define MCU pin connected to LCD D5
//#define LCD_D6	4	//define MCU pin connected to LCD D6
//#define LCD_D7	5	//define MCU pin connected to LCD D7
#define LCDP PORTB	//define MCU port connected to LCD
#define LCDDR DDRB	//define MCU direction register for port connected to LCD



void LCD_Char(uint8_t);		// send character
void LCD_Command(uint8_t);	// send command
void LCD_init(void);			//Initializes LCD
void LCD_clr(void);				//Clears LCD
void print_str(const char *text);
#endif

