/*-----------------------------------------------
 * irmpsystem.h - system specific includes and defines
 * *-----------------------------------*/

#ifndef _IRMPSYSTEM_H_
#define _IRMPSYSTEM_H_

#if !defined(_IRMP_H_) && !defined(_IRSND_H_)
#  error please include only irmp.h or irsnd.h, not irmpsystem.h
#endif


#  define ATMEL_AVR                                                                 // ATMEL AVR

#include <string.h>

#  include <stdint.h>
#  include <stdio.h>
#  include <avr/io.h>
#  include <util/delay.h>
#  include <avr/pgmspace.h>
#  include <avr/interrupt.h>
#  define IRSND_OC2                     0       // OC2
#  define IRSND_OC2A                    1       // OC2A
#  define IRSND_OC2B                    2       // OC2B
#  define IRSND_OC0                     3       // OC0
#  define IRSND_OC0A                    4       // OC0A
#  define IRSND_OC0B                    5       // OC0B

#  define IRSND_XMEGA_OC0A              0       // OC0A
#  define IRSND_XMEGA_OC0B              1       // OC0B
#  define IRSND_XMEGA_OC0C              2       // OC0C
#  define IRSND_XMEGA_OC0D              3       // OC0D
#  define IRSND_XMEGA_OC1A              4       // OC1A
#  define IRSND_XMEGA_OC1B              5       // OC1B



#ifndef TRUE
#  define TRUE                          1
#  define FALSE                         0
#endif

#define IRMP_PACKED_STRUCT              __attribute__ ((__packed__))

typedef struct IRMP_PACKED_STRUCT
{
    uint8_t                             protocol;                                   // protocol, e.g. NEC_PROTOCOL
    uint16_t                            address;                                    // address
    uint16_t                            command;                                    // command
    uint8_t                             flags;                                      // flags, e.g. repetition
} IRMP_DATA;

#endif // _IRMPSYSTEM_H_
