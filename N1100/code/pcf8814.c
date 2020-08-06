/*
 * Interface with Philips PCF8814 (or compatible) LCDs.
 the LCD communicate with ucontroller over the 3-line serial interface
 */
#include "pcf8814.h"

/*
	flags used to understand by lcd if the bits is taken as command or store in ram
*/
#define CMD  0
#define DATA 1

// The size of the display, in pixels...
#define height 65
#define width 96



#define contrast 0x05

/*
  some constants that will be ored with command to effect
    ON : turn on the command
    OFF : turn off the command
    DISPLAY: turn display on/of used with MODE only, (MODE|DISPLAY|ON/OFF)
    ALL : turn on all , only used with MODE , (MODE|ALL|ON/OFF) use off for normal display
    INVERT : invert pixels, only used with MODE , (MODE|INVERT|ON/OFF) , it bring lcd into normal form use off
  *note: you can use (MODE|ALL/INVERT|OFF)  to bring lcd into normal mode
*/
#define ON 0x01
#define OFF 0x00
#define ALL 0x04
#define INVERT 0x06
#define DISPLAY 0x0E

/*
	Command list of list
        LCD_NOP                                 : no operation
	MODE				: lcd  mode, MODE|(ALL/INVERT/DISPLAY|ON/OFF)
	LCD_VOB_MSB				: use LCD_VOB_MSB|0x04 ,the value after | is a mystry,dont mess(previos notice)
	LCD_VOB_LSB				: use LCD_VOB_LSB|(contrast value,0x00 to 0x1F)
	LCD_CHARGE_PUMP_ON 		: read the datasheet , i could nt understand
		voltage muliplication        value
            X2						      	0x00
            X3						      	0x01
            X4					      		0x02
            X5						      	0x03
	LCD_RAM_ADDR_MODE		: use LCD_RAM_ADDR_MODE|(conditon ,OFF/ON),write in RAM,
								 OFF : write horizontally (by default)
								 ON : write vertically
	LCD_CHANGE_ROW_LSB				: accessed by LCD_ROW_LSB|(b3 b2 b1 b0), last four bits of the address
	LCD_CHANGE_ROW_MSB				: accessed by LCD_ROW_MSB|(b6 b5 b4),first 3 bits of the address; alias is 0x18
	LCD_CHANGE_COL					: move to col,LCD_COL|(b2 b1 b0)
	LCD_MIRROR_Y			: mirror on y axis , use(LCD_MIRROR_Y| condition 0x08 or OFF)
								turn on/enable mirroring, conditon->0x08 , dont use ON because its 0x01
								turn off/disable mirroring, conditon->OFF
	LCD_MIRROR_X			: turn on mirroring on x axis . this is a speical instruction & 
                                          i couldt found|dont exists reset counter; its alias is 0xA0,didnt worked,
                                          and datasheet says , NOP: MX is pad selected?
	LCD_EXT_OSC				: use a external oscillator (LCD_EXT_OSC|ON / OFF)
	LCD_SOFT_RESET			: internal or software reset
 * special instruction: use 1 not ON for enabling LCD_MIRROR_X
*/
#define LCD_NOP 0xE3
#define MODE 0xA0
#define LCD_VOB_MSB 0x20
#define LCD_VOB_LSB 0x80
#define LCD_CHARGE_PUMP_ON 0x2F
#define LCD_RAM_ADDR_MODE 0xAA
#define LCD_CHANGE_ROW_LSB 0x00
#define LCD_CHANGE_ROW_MSB 0x10
#define LCD_CHANGE_COL 0xB0
#define LCD_MIRROR_Y 0xC0
#define LCD_MIRROR_X 0xA0
#define LCD_EXT_OSC 0x3A
#define LCD_SOFT_RESET 0xE2

/*----------------------------------------------------------------------------------------------*/
/* ******  PCD8544 - Interface with Philips PCD8544 (or compatible) LCDs. ****** */

// The 7-bit ASCII character set...
const PROGMEM unsigned char charset[][5] = {
  { 0x00, 0x00, 0x00, 0x00, 0x00 },  // 20 space
  { 0x00, 0x00, 0x5f, 0x00, 0x00 },  // 21 !
  { 0x00, 0x07, 0x00, 0x07, 0x00 },  // 22 "
  { 0x14, 0x7f, 0x14, 0x7f, 0x14 },  // 23 #
  { 0x24, 0x2a, 0x7f, 0x2a, 0x12 },  // 24 $
  { 0x23, 0x13, 0x08, 0x64, 0x62 },  // 25 %
  { 0x36, 0x49, 0x55, 0x22, 0x50 },  // 26 &
  { 0x00, 0x05, 0x03, 0x00, 0x00 },  // 27 '
  { 0x00, 0x1c, 0x22, 0x41, 0x00 },  // 28 (
  { 0x00, 0x41, 0x22, 0x1c, 0x00 },  // 29 )
  { 0x14, 0x08, 0x3e, 0x08, 0x14 },  // 2a *
  { 0x08, 0x08, 0x3e, 0x08, 0x08 },  // 2b +
  { 0x00, 0x50, 0x30, 0x00, 0x00 },  // 2c ,
  { 0x08, 0x08, 0x08, 0x08, 0x08 },  // 2d -
  { 0x00, 0x60, 0x60, 0x00, 0x00 },  // 2e .
  { 0x20, 0x10, 0x08, 0x04, 0x02 },  // 2f /
  { 0x3e, 0x51, 0x49, 0x45, 0x3e },  // 30 0
  { 0x00, 0x42, 0x7f, 0x40, 0x00 },  // 31 1
  { 0x42, 0x61, 0x51, 0x49, 0x46 },  // 32 2
  { 0x21, 0x41, 0x45, 0x4b, 0x31 },  // 33 3
  { 0x18, 0x14, 0x12, 0x7f, 0x10 },  // 34 4
  { 0x27, 0x45, 0x45, 0x45, 0x39 },  // 35 5
  { 0x3c, 0x4a, 0x49, 0x49, 0x30 },  // 36 6
  { 0x01, 0x71, 0x09, 0x05, 0x03 },  // 37 7
  { 0x36, 0x49, 0x49, 0x49, 0x36 },  // 38 8
  { 0x06, 0x49, 0x49, 0x29, 0x1e },  // 39 9
  { 0x00, 0x36, 0x36, 0x00, 0x00 },  // 3a :
  { 0x00, 0x56, 0x36, 0x00, 0x00 },  // 3b ;
  { 0x08, 0x14, 0x22, 0x41, 0x00 },  // 3c <
  { 0x14, 0x14, 0x14, 0x14, 0x14 },  // 3d =
  { 0x00, 0x41, 0x22, 0x14, 0x08 },  // 3e >
  { 0x02, 0x01, 0x51, 0x09, 0x06 },  // 3f ?
  { 0x32, 0x49, 0x79, 0x41, 0x3e },  // 40 @
  { 0x7e, 0x11, 0x11, 0x11, 0x7e },  // 41 A
  { 0x7f, 0x49, 0x49, 0x49, 0x36 },  // 42 B
  { 0x3e, 0x41, 0x41, 0x41, 0x22 },  // 43 C
  { 0x7f, 0x41, 0x41, 0x22, 0x1c },  // 44 D
  { 0x7f, 0x49, 0x49, 0x49, 0x41 },  // 45 E
  { 0x7f, 0x09, 0x09, 0x09, 0x01 },  // 46 F
  { 0x3e, 0x41, 0x49, 0x49, 0x7a },  // 47 G
  { 0x7f, 0x08, 0x08, 0x08, 0x7f },  // 48 H
  { 0x00, 0x41, 0x7f, 0x41, 0x00 },  // 49 I
  { 0x20, 0x40, 0x41, 0x3f, 0x01 },  // 4a J
  { 0x7f, 0x08, 0x14, 0x22, 0x41 },  // 4b K
  { 0x7f, 0x40, 0x40, 0x40, 0x40 },  // 4c L
  { 0x7f, 0x02, 0x0c, 0x02, 0x7f },  // 4d M
  { 0x7f, 0x04, 0x08, 0x10, 0x7f },  // 4e N
  { 0x3e, 0x41, 0x41, 0x41, 0x3e },  // 4f O
  { 0x7f, 0x09, 0x09, 0x09, 0x06 },  // 50 P
  { 0x3e, 0x41, 0x51, 0x21, 0x5e },  // 51 Q
  { 0x7f, 0x09, 0x19, 0x29, 0x46 },  // 52 R
  { 0x46, 0x49, 0x49, 0x49, 0x31 },  // 53 S
  { 0x01, 0x01, 0x7f, 0x01, 0x01 },  // 54 T
  { 0x3f, 0x40, 0x40, 0x40, 0x3f },  // 55 U
  { 0x1f, 0x20, 0x40, 0x20, 0x1f },  // 56 V
  { 0x3f, 0x40, 0x38, 0x40, 0x3f },  // 57 W
  { 0x63, 0x14, 0x08, 0x14, 0x63 },  // 58 X
  { 0x07, 0x08, 0x70, 0x08, 0x07 },  // 59 Y
  { 0x61, 0x51, 0x49, 0x45, 0x43 },  // 5a Z
  { 0x00, 0x7f, 0x41, 0x41, 0x00 },  // 5b [
  { 0x02, 0x04, 0x08, 0x10, 0x20 },  // 5c backslash 
  { 0x00, 0x41, 0x41, 0x7f, 0x00 },  // 5d ]
  { 0x04, 0x02, 0x01, 0x02, 0x04 },  // 5e ^
  { 0x40, 0x40, 0x40, 0x40, 0x40 },  // 5f _
  { 0x00, 0x01, 0x02, 0x04, 0x00 },  // 60 `
  { 0x20, 0x54, 0x54, 0x54, 0x78 },  // 61 a
  { 0x7f, 0x48, 0x44, 0x44, 0x38 },  // 62 b
  { 0x38, 0x44, 0x44, 0x44, 0x20 },  // 63 c
  { 0x38, 0x44, 0x44, 0x48, 0x7f },  // 64 d
  { 0x38, 0x54, 0x54, 0x54, 0x18 },  // 65 e
  { 0x08, 0x7e, 0x09, 0x01, 0x02 },  // 66 f
  { 0x0c, 0x52, 0x52, 0x52, 0x3e },  // 67 g
  { 0x7f, 0x08, 0x04, 0x04, 0x78 },  // 68 h
  { 0x00, 0x44, 0x7d, 0x40, 0x00 },  // 69 i
  { 0x20, 0x40, 0x44, 0x3d, 0x00 },  // 6a j 
  { 0x7f, 0x10, 0x28, 0x44, 0x00 },  // 6b k
  { 0x00, 0x41, 0x7f, 0x40, 0x00 },  // 6c l
  { 0x7c, 0x04, 0x18, 0x04, 0x78 },  // 6d m
  { 0x7c, 0x08, 0x04, 0x04, 0x78 },  // 6e n
  { 0x38, 0x44, 0x44, 0x44, 0x38 },  // 6f o
  { 0x7c, 0x14, 0x14, 0x14, 0x08 },  // 70 p
  { 0x08, 0x14, 0x14, 0x18, 0x7c },  // 71 q
  { 0x7c, 0x08, 0x04, 0x04, 0x08 },  // 72 r
  { 0x48, 0x54, 0x54, 0x54, 0x20 },  // 73 s
  { 0x04, 0x3f, 0x44, 0x40, 0x20 },  // 74 t
  { 0x3c, 0x40, 0x40, 0x20, 0x7c },  // 75 u
  { 0x1c, 0x20, 0x40, 0x20, 0x1c },  // 76 v
  { 0x3c, 0x40, 0x30, 0x40, 0x3c },  // 77 w
  { 0x44, 0x28, 0x10, 0x28, 0x44 },  // 78 x
  { 0x0c, 0x50, 0x50, 0x50, 0x3c },  // 79 y
  { 0x44, 0x64, 0x54, 0x4c, 0x44 },  // 7a z
  { 0x00, 0x08, 0x36, 0x41, 0x00 },  // 7b {
  { 0x00, 0x00, 0x7f, 0x00, 0x00 },  // 7c |
  { 0x00, 0x41, 0x36, 0x08, 0x00 },  // 7d }
  { 0x10, 0x08, 0x08, 0x10, 0x08 },  // 7e ~
  { 0x00, 0x00, 0x00, 0x00, 0x00 }   // 7f 
};

//=============================================


void init_lcd(){
    column = 0;
    line = 0;
  // control pins as outputs
  LCD_DDR = (1 << reset) | (1 << sdin) |(1 << sclk) ;
  LCD_PORT = 1; // reset = low, sclk = low, reset = High
  
	
  LCD_PORT &= ~(1 << reset);  // reset = LOW
	_delay_ms(10);  // at least 5ms
	LCD_PORT |= (1 << reset);  //reset = HIGH

	send(CMD, LCD_CHARGE_PUMP_ON);   //LCD_CHARGE_PUMP_ON == 0x2F
	
	// contrast == 0x05
  send(CMD, LCD_VOB_MSB|0x04); //0x20|0x04 = 0x24
	send(CMD, LCD_VOB_LSB|(contrast & 0x1F)); // 0x80|0x05=0x85

	send(CMD, MODE|DISPLAY|ON); //0xA0|0x0E|0x01 = 0xAF
	send(CMD, MODE|ALL|OFF);  // 0xA0|0x04|0x00 = 0xA4
	send(CMD, MODE|INVERT|OFF);//0xA0|0x06|0x00 = 0xA6

	_delay_ms(200);
	cls();
}

//==========================================
// clear the screen
void cls(){
	setCursor(0, 0);
	int index;
	for(index=0; index < 864; index++)
		send(DATA, 0x00);
	
	setCursor(0, 0);
	
	_delay_ms(200);
}
//===================================
//Normal screen (black on white)
void setNormal(){
  send(CMD, MODE|INVERT|OFF);
}

//=============================================
// Inverse mode (white on black)
void setInverse(){
	send(CMD, MODE|INVERT|ON);
}

//==================================
// clear current line
void clear_cLine(){
    setCursor(0, line);

    for (unsigned char i = 0; i < width; i++) {
        send(DATA, 0x00);
    }

    setCursor(0, line);
}
//=============================================
// clear a given line
void clear_aLine(unsigned char aline){
    setCursor(0, aline);

    for (unsigned char i = 0; i < width; i++) {
        send(DATA, 0x00);
    }

    setCursor(0, aline);
}

//=============================================
void setCursor(unsigned char x, unsigned char y){
    column = (x % width);
    line = (y % (height/9 + 1));

	send(CMD, LCD_CHANGE_ROW_LSB | ( column & 0x0F));
	send(CMD, LCD_CHANGE_ROW_MSB | ( (column >> 4) & 0x07 ));
  send(CMD, LCD_CHANGE_COL | ( line & 0x0F ));
}

//=============================================
void write(uint8_t chr){

    const unsigned char *glyph;
    unsigned char pgm_buffer[5];
	unsigned char i ;

    // ASCII 7-bit only...
    if (chr >= 0x80) return;

    if (chr >= ' ') {
        // Regular ASCII characters are kept in flash to save RAM...
        memcpy_P(pgm_buffer, &charset[chr - ' '], sizeof(pgm_buffer));
        glyph = pgm_buffer;
    } 

    else {
            // Default to a space character if unset...
            memcpy_P(pgm_buffer, &charset[0], sizeof(pgm_buffer));
            glyph = pgm_buffer;
    }

    // Output one column at a time...
    for (i = 0; i < 5; i++) {
        send(DATA, glyph[i]);
    }

    // One column between characters...
    send(DATA, 0x00);

    // Update the cursor position...
    column = (column + 6) % width;

    if (column == 0) {
       line = (line + 1) % (height/9 + 1);
    }

}
//===========================================
// print a string in the current position
void print(unsigned char *str){
  while(*str) write(*str++);
}
//=============================================
void send(unsigned char type, unsigned char data){
    unsigned char i;
    
    // send D/C bit
    if(type) LCD_PORT |= (1 << sdin);  //if data sdin = HIGH
    else LCD_PORT &= ~(1 << sdin);  //if command sdin = low   
    
    LCD_PORT |= (1 << sclk);  //sclk = HIGH
    LCD_PORT &= ~(1 << sclk);  // sclk = LOW
    
    //send byte Msbit first
    for ( i=0x80;i>0;i=i>>1){
      if(data & i)   LCD_PORT |= (1 << sdin);  //sdin = HIGH
      else LCD_PORT &= ~(1 << sdin);  //sdin = low  
      LCD_PORT |= (1 << sclk);  //sclk = HIGH
      LCD_PORT &= ~(1 << sclk);  // sclk = LOW
	}

}
//===================================
	// draw image bitmap stored in flash,  row by row
void drawBitmap(unsigned char *bitmap, unsigned char lines,  unsigned char columns){
    unsigned char *table, byte;

    for (unsigned char y = 0; y < lines; y++) {
        setCursor(0,  y);

        for (unsigned char x = 0; x < columns; x++) {
		table = (unsigned char*)&(bitmap[x +y*96]);
        byte = pgm_read_byte(table);           
        send(1, byte);
        }
    }

}
