#include <avr/eeprom.h>
#include "random.h"


/* ===========================================================
 a simple and lightweight PRNG (Pseudo Random Number Generator) 
 which require only 116 bytes of program space.
 implementation of PRNG is based on Galois LFSR (Linear Feedback 
 Shift Register) and implements extra feature to generate pseudo 
 random seed on boot time (to enable this feature set compiler 
 flag USE_RANDOM_SEED). 
 
 Example Program Code:
 
#include <avr/io.h>
#include <util/delay.h>
#include "random.h"

#define    LED_PIN    PB0


int
main(void)
{
    uint16_t number;

    // setup 
    DDRB |= _BV(LED_PIN); // set LED pin as OUTPUT
    
    random_init(0xabcd); // initialize 16 bit seed

    // loop, simple realization of pseudo random LED blinking 
    while (1) {
        number = random();
        if (number & 0x01) { // odd number
            PORTB |= _BV(LED_PIN);
        } else { // even number
            PORTB &= ~_BV(LED_PIN);
        }
        _delay_ms(100);
    }
}
==============================================================*/


static uint16_t random_number = 0;

static uint16_t
lfsr16_next(uint16_t n)
{

    return (n >> 0x01U) ^ (-(n & 0x01U) & 0xB400U);    
}

void
random_init(uint16_t seed)
{
#ifdef USE_RANDOM_SEED
    random_number = lfsr16_next(eeprom_read_word((uint16_t *)RANDOM_SEED_ADDRESS) ^ seed);
    eeprom_write_word((uint16_t *)0, random_number);
#else
    random_number = seed;
#endif    /* !USE_RANDOM_SEED */
}

uint16_t
random(void)
{

    return (random_number = lfsr16_next(random_number)); 
}