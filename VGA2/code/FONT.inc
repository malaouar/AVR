;==============================================================================
; FONT   4x6  (inverted)
; Implements ASCII character set from 0x20 - 0x7F 
; FLash memory is organised in WORDS (two bytes) so from 0x800 to 0x880 there is 256 bytes

; First row  
.org 0x800
;    0      1    2     3      4    5     6     7     8     9     A     B     C     D     E     F
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0F, 0x0B, 0x05, 0x05, 0x09, 0x07, 0x03, 0x0b, 0x0d, 0x07, 0x05, 0x0f, 0x0f, 0x0f, 0x0f, 0x0d
.db 0x09, 0x0b, 0x03, 0x03, 0x05, 0x01, 0x09, 0x01, 0x01, 0x01, 0x0f, 0x0F, 0x0D, 0x0F, 0x07, 0x01
.db 0x0b, 0x0b, 0x03, 0x09, 0x03, 0x01, 0x01, 0x09, 0x05, 0x01, 0x0D, 0x05, 0x07, 0x05, 0x05, 0x0b
.db 0x03, 0x0b, 0x03, 0x09, 0x01, 0x05, 0x05, 0x05, 0x05, 0x05, 0x01, 0x01, 0x0F, 0x01, 0x0b, 0x0f
.db 0x07, 0x0f, 0x07, 0x0f, 0x0D, 0x0f, 0x0D, 0x0f, 0x07, 0x0B, 0x0D, 0x07, 0x03, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0B, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x09, 0x0B, 0x03, 0x09, 0x01

; second row  
.org 0x880
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0F, 0x0B, 0x05, 0x01, 0x03, 0x0d, 0x03, 0x0b, 0x0b, 0x0b, 0x0B, 0x0b, 0x0f, 0x0f, 0x0f, 0x0d
.db 0x05, 0x03, 0x0d, 0x0D, 0x05, 0x07, 0x07, 0x0D, 0x05, 0x05, 0x0b, 0x0b, 0x0B, 0x01, 0x0B, 0x0D
.db 0x05, 0x05, 0x05, 0x07, 0x05, 0x07, 0x07, 0x07, 0x05, 0x0b, 0x0D, 0x05, 0x07, 0x01, 0x01, 0x05
.db 0x05, 0x05, 0x05, 0x07, 0x0b, 0x05, 0x05, 0x05, 0x05, 0x05, 0x0d, 0x07, 0x07, 0x0D, 0x05, 0x0f
.db 0x0B, 0x03, 0x03, 0x09, 0x09, 0x09, 0x0B, 0x09, 0x03, 0x0f, 0x0f, 0x05, 0x0B, 0x01, 0x03, 0x0B
.db 0x03, 0x09, 0x09, 0x09, 0x01, 0x05, 0x05, 0x05, 0x05, 0x05, 0x01, 0x0B, 0x0B, 0x0B, 0x03, 0x01


; Third row 
.org 0x900
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0B, 0x0f, 0x05, 0x09, 0x0b, 0x01, 0x0f, 0x0b, 0x0b, 0x05, 0x01, 0x0f, 0x01, 0x0f, 0x0b
.db 0x05, 0x0B, 0x0B, 0x0b, 0x01, 0x03, 0x01, 0x0B, 0x01, 0x01, 0x0f, 0x0f, 0x07, 0x0f, 0x0D, 0x0B
.db 0x01, 0x01, 0x03, 0x07, 0x05, 0x01, 0x01, 0x01, 0x01, 0x0B, 0x0D, 0x03, 0x07, 0x05, 0x01, 0x05
.db 0x03, 0x05, 0x01, 0x0B, 0x0b, 0x05, 0x05, 0x01, 0x0b, 0x0b, 0x0b, 0x07, 0x0b, 0x0D, 0x0f, 0x0f
.db 0x0f, 0x09, 0x05, 0x07, 0x05, 0x05, 0x01, 0x05, 0x05, 0x0B, 0x0D, 0x03, 0x0B, 0x01, 0x05, 0x05
.db 0x05, 0x05, 0x07, 0x03, 0x0B, 0x05, 0x05, 0x01, 0x0B, 0x05, 0x09, 0x07, 0x0f, 0x0D, 0x0f, 0x01


; Fourth row  
.org 0x980
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0F, 0x0f, 0x01, 0x03, 0x07, 0x05, 0x0f, 0x0b, 0x0b, 0x0F, 0x0b, 0x0b, 0x0f, 0x0f, 0x07
.db 0x05, 0x0B, 0x07, 0x0d, 0x0d, 0x0D, 0x05, 0x07, 0x05, 0x0D, 0x0b, 0x0b, 0x0B, 0x01, 0x0B, 0x0F
.db 0x07, 0x05, 0x05, 0x07, 0x05, 0x07, 0x07, 0x05, 0x05, 0x0b, 0x05, 0x05, 0x07, 0x05, 0x05, 0x05
.db 0x07, 0x01, 0x03, 0x0d, 0x0b, 0x05, 0x0b, 0x01, 0x05, 0x0b, 0x07, 0x07, 0x0D, 0x0D, 0x0f, 0x0f
.db 0x0f, 0x05, 0x05, 0x07, 0x05, 0x03, 0x0B, 0x01, 0x05, 0x0B, 0x0D, 0x03, 0x0B, 0x01, 0x05, 0x05
.db 0x05, 0x05, 0x07, 0x09, 0x0B, 0x05, 0x05, 0x01, 0x0B, 0x09, 0x03, 0x0B, 0x0B, 0x0B, 0x0f, 0x01


; Fifth row  
.org 0xA00
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0b, 0x0f, 0x05, 0x0B, 0x0D, 0x09, 0x0F, 0x0d, 0x07, 0x0F, 0x0f, 0x07, 0x0F, 0x0B, 0x07
.db 0x03, 0x0B, 0x01, 0x03, 0x0D, 0x03, 0x01, 0x07, 0x01, 0x03, 0x0F, 0x07, 0x0D, 0x0F, 0x07, 0x0B
.db 0x09, 0x05, 0x03, 0x09, 0x03, 0x01, 0x07, 0x09, 0x05, 0x01, 0x0B, 0x05, 0x01, 0x05, 0x05, 0x0b
.db 0x07, 0x09, 0x05, 0x03, 0x0b, 0x09, 0x0b, 0x05, 0x05, 0x0b, 0x01, 0x01, 0x0F, 0x01, 0x0f, 0x01
.db 0x0f, 0x01, 0x03, 0x09, 0x09, 0x09, 0x0B, 0x0D, 0x05, 0x0B, 0x05, 0x05, 0x01, 0x05, 0x05, 0x0B
.db 0x03, 0x09, 0x07, 0x03, 0x09, 0x09, 0x0B, 0x01, 0x05, 0x0D, 0x01, 0x09, 0x0B, 0x03, 0x0f, 0x01


; Sixth row 
.org 0xA80
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0B, 0x0f, 0x0f, 0x0B, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
.db 0x07, 0x0D, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0B, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f


; Blank row
.ORG 0xB00
.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff

; .ORG 0xB80


;=====================