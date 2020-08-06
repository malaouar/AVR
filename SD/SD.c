/*******************************************************************/
/*          SD diriver for ATMEGA328P                                  */
/*******************************************************************/

#include <avr/io.h>
#include <stdint.h>
#include <inttypes.h>
#include <string.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>


#define CS  2    // SDCARD CS PIN
 uint8_t buffer[512];

//===================================
//read and write one byte over SPI
uint8_t SPI_WriteByte(uint8_t val){
    SPDR = val;
    while(!(SPSR & _BV(SPIF)));
    return SPDR;
}

//===========================
//SPI initialize
void SPI_Init(void){
	DDRB |= _BV(2)|_BV(3)|_BV(5); //  PORTB 2,3,5 outputs (CS, MOSI, CLCK)
	SPCR =   _BV(SPE)|_BV(MSTR)|_BV(SPR1)|_BV(SPR0); // low speed SPI
	SPSR &= ~_BV(SPI2X);

	PORTB |=  _BV(CS);  // CS=1
}

//===================================
//sd send command
uint8_t SD_SendCmd(uint8_t cmd, uint32_t arg){
	uint8_t r1;
	uint8_t retry=0;
	
	SPI_WriteByte(0xff);
	PORTB &= ~_BV(CS)  ; // CS=0
	
	SPI_WriteByte(cmd | 0x40);	//send command
	SPI_WriteByte(arg>>24);
	SPI_WriteByte(arg>>16);
	SPI_WriteByte(arg>>8);
	SPI_WriteByte(arg);
	SPI_WriteByte(0x95);
	
	while((r1 = SPI_WriteByte(0xff)) == 0xff)	//wait response
		if(retry++ > 0xfe) break;					//time out error

	PORTB |=  _BV(CS);     //CS=1
	SPI_WriteByte(0xff);				// extra 8 CLK

	return r1;					//return state
}

//================================
//reset sd card (software)
uint8_t SD_Init(void){
	uint8_t i;
	uint8_t retry;
	uint8_t r1=0;
	retry = 0;
	do{
		for(i=0;i<10;i++) SPI_WriteByte(0xff);
		r1 = SD_SendCmd(0, 0);	//send idle command
		retry++;
		if(retry>0xfe) return 1;		//time out --> fail
	} while(r1 != 0x01);	

	retry = 0;
	do{
		r1 = SD_SendCmd(1, 0);	//send active command
		retry++;
		if(retry>0xfe) return 1;		//time out --> fail
	} while(r1);
	
	
  SPCR =  _BV(SPE)|_BV(MSTR);  // high speed SPI
	SPSR |= _BV(SPI2X);

	r1 = SD_SendCmd(16, 512);	//set sector size to 512
	return 0;		//success 
}

//===================================
//write one sector 
uint8_t SD_WriteSector(uint32_t no_secteur){
	uint8_t r1;
	uint16_t i;
	uint16_t retry=0;

	r1 = SD_SendCmd(24, no_secteur<<9);	//send command
	if(r1 != 0x00)
		return r1;

	PORTB &= ~_BV(CS);  //CS=0
	
	SPI_WriteByte(0xff);
	SPI_WriteByte(0xff);
	SPI_WriteByte(0xff);

	SPI_WriteByte(0xfe);			//send start byte "token"
	
	for(i=0; i<512; i++){		//send 512 bytes data
		SPI_WriteByte(buffer[i]);
	}
	
	SPI_WriteByte(0xff);			//dummy crc
	SPI_WriteByte(0xff);
	
	r1 = SPI_WriteByte(0xff);
	
	if( (r1&0x1f) != 0x05)	//judge if it successful
	{
		PORTB |=  _BV(CS); //CS=1
		return r1;
	}
	
	//wait no busy
	while(!SPI_WriteByte(0xff)) if(retry++ > 0xfffe){
      PORTB |=  _BV(CS); //CS=1
      return 1;  //fail
      }

	PORTB |=  _BV(CS); //CS=1
	SPI_WriteByte(0xff);// extra 8 CLK

	return 0; //success
}

//====================  NOT TESTED =========
//read one sector
uint8_t SD_ReadSector(uint32_t no_secteur){
	uint8 r1;
	uint16_t i;
	uint16_t retry=0;

	r1 = SD_SendCmd(17, no_secteur<<9);	//read command
	
	if(r1 != 0x00)  return r1;  // fail

	PORTB &= ~_BV(CS_PIN);       //CS=0
  //wait to start recieve data
	while(SPI_WriteByte(0xff) != 0xfe) if(retry++ > 0xfffe){
	   PORTB |=  _BV(CS_PIN); //CS=1
     return 1;
     }

	for(i=0; i<512; i++)	    //read 512 bytes
	{
		buffer[i] = SPI_WriteByte(0xff);
	}

	SPI_WriteByte(0xff);         //dummy crc
	SPI_WriteByte(0xff);
	
	PORTB |=  _BV(CS_PIN);         //CS=1
	SPI_WriteByte(0xff);         // extra 8 CLK

	return 0; //success
}


//===========================================
void fillram(void)	{ // fill RAM sector with ASCII characters
	int i,c;
	char mystring[14] = "SEB-SEB LAOUAR";
	c = 0;
	for (i=0;i<=512;i++) {
		buffer[i] = mystring[c];
		c++;
		if (c > 13) c = 0; 
	}
}
//=================================
void blink(uint8_t n){
  uint8_t i;
  for(i=0; i<n; i++){
  PORTB &= ~(1<<0); // led on
  _delay_ms(500);
  PORTB |= (1<<0); // led off
  _delay_ms(500);
  }
}

//======================================
int main(void) {
    DDRB |= (1<<0); // PB0 output for LED
    
    set_sleep_mode(SLEEP_MODE_IDLE); //CPU is put on sleep but all peripheral clocks are still running
    
    blink(3);
    _delay_ms(1000);
    
    SPI_Init();
	  if(SD_Init()) blink(10);
	  else{
	  blink(5);
	  fillram();
	  SD_WriteSector(100);
	  }

    for(;;) sleep_mode();
    
	return 0;
}

