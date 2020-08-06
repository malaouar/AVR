/*
 * PCF8814 - Interface with Philips PCF8814 (or compatible) LCDs.
 */


#ifndef PCF8814_H
#define PCF8814_H

#include <avr/pgmspace.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdbool.h>



        // Current cursor position...
unsigned char column;
unsigned char line;


        // All the pins can be changed from the default values...
#define LCD_PORT  PORTB
#define LCD_DDR  DDRB
#define sclk  2   // clock  (display pin 2) on PORTB 2 
#define sdin  1   //data-in (display pin 3) on PORTB 1 
#define reset  0   // reset  (display pin 8) on PORTB 0 


        // Display initialization (dimensions in pixels)...
void init_lcd();
				
		
		//rotate display 180 ... in fact mirror x and mirror y
void rotate(bool value); 

        // clear screen : Erase everything on the display...
void cls();

//Normal screen (black on white)
void setNormal();

//invert screen (white on black)
void setInverse();

// clear a given line
void clear_aLine(unsigned char aline);

void clear_cLine();  // ...or just the current line
        
        // Place the cursor at position (column, line)...
void setCursor(unsigned char x, unsigned char y);

        // Write an ASCII character at the current cursor position (7-bit)...
void write(uint8_t chr);

    // print a string in the current position
void print(unsigned char *str);

        // Send a command or data to the display...
void send(unsigned char type, unsigned char data);

// draw image bitmap  stored in flash
void drawBitmap(unsigned char *bitmap, unsigned char lines,  unsigned char columns);

#endif  /* PCF8814_H */

