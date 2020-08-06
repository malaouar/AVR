
#ifndef _IRMP_H_
#define _IRMP_H_

#include "irmpsystem.h"

#ifndef IRMP_USE_AS_LIB
#  include "irmpconfig.h"
#endif

#if defined (ATMEL_AVR)
#  define _CONCAT(a,b)                          a##b
#  define CONCAT(a,b)                           _CONCAT(a,b)
#  define IRMP_PORT                             CONCAT(PORT, IRMP_PORT_LETTER)
#  define IRMP_DDR                              CONCAT(DDR, IRMP_PORT_LETTER)
#  define IRMP_PIN                              CONCAT(PIN, IRMP_PORT_LETTER)
#  define IRMP_BIT                              IRMP_BIT_NUMBER
#  define input(x)                              ((x) & (1 << IRMP_BIT))
#endif

#if IRMP_SUPPORT_TECHNICS_PROTOCOL == 1
#  undef IRMP_SUPPORT_MATSUSHITA_PROTOCOL
#  define IRMP_SUPPORT_MATSUSHITA_PROTOCOL      1
#endif

#if IRMP_SUPPORT_DENON_PROTOCOL == 1 && IRMP_SUPPORT_RUWIDO_PROTOCOL == 1
#  warning DENON protocol conflicts wih RUWIDO, please enable only one of both protocols
#  warning RUWIDO protocol disabled
#  undef IRMP_SUPPORT_RUWIDO_PROTOCOL
#  define IRMP_SUPPORT_RUWIDO_PROTOCOL          0
#endif

#if IRMP_SUPPORT_KASEIKYO_PROTOCOL == 1 && IRMP_SUPPORT_PANASONIC_PROTOCOL == 1
#  warning KASEIKYO protocol conflicts wih PANASONIC, please enable only one of both protocols
#  warning PANASONIC protocol disabled
#  undef IRMP_SUPPORT_PANASONIC_PROTOCOL
#  define IRMP_SUPPORT_PANASONIC_PROTOCOL       0
#endif

#if IRMP_SUPPORT_DENON_PROTOCOL == 1 && IRMP_SUPPORT_ACP24_PROTOCOL == 1
#  warning DENON protocol conflicts wih ACP24, please enable only one of both protocols
#  warning ACP24 protocol disabled
#  undef IRMP_SUPPORT_ACP24_PROTOCOL
#  define IRMP_SUPPORT_ACP24_PROTOCOL           0
#endif

#if IRMP_SUPPORT_RC6_PROTOCOL == 1 && IRMP_SUPPORT_ROOMBA_PROTOCOL == 1
#  warning RC6 protocol conflicts wih ROOMBA, please enable only one of both protocols
#  warning ROOMBA protocol disabled
#  undef IRMP_SUPPORT_ROOMBA_PROTOCOL
#  define IRMP_SUPPORT_ROOMBA_PROTOCOL          0
#endif

#if IRMP_SUPPORT_PANASONIC_PROTOCOL == 1 && IRMP_SUPPORT_MITSU_HEAVY_PROTOCOL == 1
#  warning PANASONIC protocol conflicts wih MITSU_HEAVY, please enable only one of both protocols
#  warning MITSU_HEAVY protocol disabled
#  undef IRMP_SUPPORT_MITSU_HEAVY_PROTOCOL
#  define IRMP_SUPPORT_MITSU_HEAVY_PROTOCOL      0
#endif

#if IRMP_SUPPORT_RC5_PROTOCOL == 1 && IRMP_SUPPORT_ORTEK_PROTOCOL == 1
#  warning RC5 protocol conflicts wih ORTEK, please enable only one of both protocols
#  warning ORTEK protocol disabled
#  undef IRMP_SUPPORT_ORTEK_PROTOCOL
#  define IRMP_SUPPORT_ORTEK_PROTOCOL           0
#endif

#if IRMP_SUPPORT_RC5_PROTOCOL == 1 && IRMP_SUPPORT_S100_PROTOCOL == 1
#  warning RC5 protocol conflicts wih S100, please enable only one of both protocols
#  warning S100 protocol disabled
#  undef IRMP_SUPPORT_S100_PROTOCOL
#  define IRMP_SUPPORT_S100_PROTOCOL            0
#endif

#if IRMP_SUPPORT_NUBERT_PROTOCOL == 1 && IRMP_SUPPORT_FAN_PROTOCOL == 1
#  warning NUBERT protocol conflicts wih FAN, please enable only one of both protocols
#  warning FAN protocol disabled
#  undef IRMP_SUPPORT_FAN_PROTOCOL
#  define IRMP_SUPPORT_FAN_PROTOCOL             0
#endif

#if IRMP_SUPPORT_FDC_PROTOCOL == 1 && IRMP_SUPPORT_ORTEK_PROTOCOL == 1
#  warning FDC protocol conflicts wih ORTEK, please enable only one of both protocols
#  warning ORTEK protocol disabled
#  undef IRMP_SUPPORT_ORTEK_PROTOCOL
#  define IRMP_SUPPORT_ORTEK_PROTOCOL           0
#endif

#if IRMP_SUPPORT_ORTEK_PROTOCOL == 1 && IRMP_SUPPORT_NETBOX_PROTOCOL == 1
#  warning ORTEK protocol conflicts wih NETBOX, please enable only one of both protocols
#  warning NETBOX protocol disabled
#  undef IRMP_SUPPORT_NETBOX_PROTOCOL
#  define IRMP_SUPPORT_NETBOX_PROTOCOL          0
#endif

#if IRMP_SUPPORT_SIEMENS_PROTOCOL == 1 && F_INTERRUPTS < 15000
#  warning F_INTERRUPTS too low, SIEMENS protocol disabled (should be at least 15000)
#  undef IRMP_SUPPORT_SIEMENS_PROTOCOL
#  define IRMP_SUPPORT_SIEMENS_PROTOCOL         0
#endif

#if IRMP_SUPPORT_RUWIDO_PROTOCOL == 1 && F_INTERRUPTS < 15000
#  warning F_INTERRUPTS too low, RUWIDO protocol disabled (should be at least 15000)
#  undef IRMP_SUPPORT_RUWIDO_PROTOCOL
#  define IRMP_SUPPORT_RUWIDO_PROTOCOL          0
#endif

#if IRMP_SUPPORT_RECS80_PROTOCOL == 1 && F_INTERRUPTS < 15000
#  warning F_INTERRUPTS too low, RECS80 protocol disabled (should be at least 15000)
#  undef IRMP_SUPPORT_RECS80_PROTOCOL
#  define IRMP_SUPPORT_RECS80_PROTOCOL          0
#endif

#if IRMP_SUPPORT_RECS80EXT_PROTOCOL == 1 && F_INTERRUPTS < 15000
#  warning F_INTERRUPTS too low, RECS80EXT protocol disabled (should be at least 15000)
#  undef IRMP_SUPPORT_RECS80EXT_PROTOCOL
#  define IRMP_SUPPORT_RECS80EXT_PROTOCOL       0
#endif

#if IRMP_SUPPORT_LEGO_PROTOCOL == 1 && F_INTERRUPTS < 20000
#  warning F_INTERRUPTS too low, LEGO protocol disabled (should be at least 20000)
#  undef IRMP_SUPPORT_LEGO_PROTOCOL
#  define IRMP_SUPPORT_LEGO_PROTOCOL            0
#endif

#if IRMP_SUPPORT_SAMSUNG48_PROTOCOL == 1 && IRMP_SUPPORT_SAMSUNG_PROTOCOL == 0
#  warning SAMSUNG48 protocol needs also SAMSUNG protocol, SAMSUNG protocol enabled
#  undef IRMP_SUPPORT_SAMSUNG_PROTOCOL
#  define IRMP_SUPPORT_SAMSUNG_PROTOCOL         1
#endif

#if IRMP_SUPPORT_JVC_PROTOCOL == 1 && IRMP_SUPPORT_NEC_PROTOCOL == 0
#  warning JVC protocol needs also NEC protocol, NEC protocol enabled
#  undef IRMP_SUPPORT_NEC_PROTOCOL
#  define IRMP_SUPPORT_NEC_PROTOCOL             1
#endif

#if IRMP_SUPPORT_NEC16_PROTOCOL == 1 && IRMP_SUPPORT_NEC_PROTOCOL == 0
#  warning NEC16 protocol needs also NEC protocol, NEC protocol enabled
#  undef IRMP_SUPPORT_NEC_PROTOCOL
#  define IRMP_SUPPORT_NEC_PROTOCOL             1
#endif

#if IRMP_SUPPORT_NEC42_PROTOCOL == 1 && IRMP_SUPPORT_NEC_PROTOCOL == 0
#  warning NEC42 protocol needs also NEC protocol, NEC protocol enabled
#  undef IRMP_SUPPORT_NEC_PROTOCOL
#  define IRMP_SUPPORT_NEC_PROTOCOL             1
#endif

#if IRMP_SUPPORT_LGAIR_PROTOCOL == 1 && IRMP_SUPPORT_NEC_PROTOCOL == 0
#  warning LGAIR protocol needs also NEC protocol, NEC protocol enabled
#  undef IRMP_SUPPORT_NEC_PROTOCOL
#  define IRMP_SUPPORT_NEC_PROTOCOL             1
#endif

#if IRMP_SUPPORT_RCMM_PROTOCOL == 1 && F_INTERRUPTS < 20000
#  warning F_INTERRUPTS too low, RCMM protocol disabled (should be at least 20000)
#  undef IRMP_SUPPORT_RCMM_PROTOCOL
#  define IRMP_SUPPORT_RCMM_PROTOCOL            0
#endif

#if F_INTERRUPTS > 20000
#error F_INTERRUPTS too high (should be not greater than 20000)
#endif

#include "irmpprotocols.h"

#define IRMP_FLAG_REPETITION            0x01

#ifdef __cplusplus
extern "C"
{
#endif

extern void                             irmp_init (void);
extern uint_fast8_t                     irmp_get_data (IRMP_DATA *);
extern uint_fast8_t                     irmp_ISR (void);

#if IRMP_PROTOCOL_NAMES == 1
extern const char * const               irmp_protocol_names[IRMP_N_PROTOCOLS + 1] PROGMEM;
#endif

#if IRMP_USE_CALLBACK == 1
extern void                             irmp_set_callback_ptr (void (*cb)(uint_fast8_t));
#endif // IRMP_USE_CALLBACK == 1

#ifdef __cplusplus
}
#endif

#endif /* _IRMP_H_ */
