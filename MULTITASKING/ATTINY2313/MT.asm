;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MULTITASKING IN AVR 
; ATTINY2313  - internal 8MHz (8/1):
;   Hfuse: 1101 1111 ---> DF
;   Lfuse: 1110 0100 ---> E4
;------------------------------------------------------------------
;TASK:
;At present, there are 3 tasks in this program. Also we can add
;more by editing the TASKx_STACK_BEGIN, TOTAL_TASK and adding few 
;lines on the start_up code....
;Each task toggle a bit of PORTD with a constant delay, but the 
;delay for each task is different. Thus we could observe the LEDs
;at different port bits are toggling at different speed. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "tn2313def.inc"
;
; we  store the TASK INDEX and the most recent stack pointer address for each task in the kernel space.
.EQU    TOTAL_TASK=3   ; we have 3 tasks
.EQU    TASK_INDEX=(RAMEND)  ; 1 bytes 
; stack pointer backup table (or array) is 3 bytes (3tasks x 1bytes) , 2313 Stack Pointer has only 8bits (SPL)
.EQU    SP_BACKUP_BASE=(RAMEND-2)   ;stack pointer backup array base 

;The stack size for each task = (user defined data space per task) + 32 (for GPR) + 1 register for SREG +2 registers for PC.
; So: The stack size for each task = (user defined data space per task) + 35

; Here, du to RAM limitation, we save only the high 16 registers
; each task get  30 bytes of RAM space: 11 ( for our needs: calls ...) + 16 (registers) + 1 (status_reg) + 2 (PC)  
.EQU    TASK1_STACK_BEGIN=(RAMEND-5)   ;initial stack pointer for task1: (3+2=5)
.EQU    TASK2_STACK_BEGIN=(RAMEND-35)  ;initial stack pointer for task2
.EQU    TASK3_STACK_BEGIN=(RAMEND-65)  ;initial stack pointer for task3
;.EQU    TASK4_STACK_BEGIN=(RAMEND-95)  ;initial stack pointer for task4
;
.CSEG
.ORG 0x0000                            ;reset vector
    rjmp startup                    ;jump to startup code
.ORG  0x0005                          ;    Timer/Counter1 Overflow
    rjmp context_switch                ;jump to context_switching interrupt service routine
;   
startup:
;timer1_init                            
    ldi r16, 0b00000001    ; (1<<CS10) prescaler=1 
    out TCCR1B, r16
    ldi r16, 0b10000000  ;(1<<TOV1)
    out TIMSK, r16       ; Enable Timer/Counter1 Overflow interrupt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INITIAL SP BACKUP ON AN ARRAY:                
;this is an initial setup to fill the stack pointer backup
;array with initial stack pointers of each task....
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    clr r31
    ldi r30,LOW(SP_BACKUP_BASE)         ;initializing Z register(pointer) SP_BACKUP_BASE (lower 8 bit)
;
    ldi r16, LOW(TASK1_STACK_BEGIN)         
    st z, r16                         
    out SPL, r16           ; we start with task1             
;---------------------------------------
;  in the ISR routine we pop the 16 registers + status_reg + reti (pops PC) 
    ldi r16, LOW(TASK2_STACK_BEGIN-19)  ; 16 high registers + status_reg + PC (2bytes)= 19
    st -z, r16
;---------------------------------------
    ldi r16, LOW(TASK3_STACK_BEGIN-19)
    st -z, r16
;---------------------------------------
;
;YOUR CODE HERE
;DO AS ABOVE IF YOU HAVE TO ADD EXTRA TASK :-)
;
;---------------------------------------
    clr r16
    sts TASK_INDEX, r16  ; we start with task1 --> Index = 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PROGRAM COUNTER INITIALIZATION:
;This is an initial setup to keep all the 
;task starting address for task2 to task 7 in
;the stack head so that the reti instruction at
;the end of context switching can load the PC with
;the task starting address for the first time..
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;program counter initialization for task1
    ;ldi r16, LOW(TASK1)           ; cose we start with task1 so we don't need this 
    ;sts TASK2_STACK_BEGIN, r16
    ;ldi r16, HIGH(TASK1)
    ;sts TASK2_STACK_BEGIN-1, r16
;-------------------------------------------
;program counter initialization for task2
    ldi r16, LOW(TASK2)
    sts TASK2_STACK_BEGIN, r16
    ldi r16, HIGH(TASK2)
    sts TASK2_STACK_BEGIN-1, r16
;
;program counter initialization for task3
    ldi r16, LOW(TASK3)
    sts TASK3_STACK_BEGIN, r16
    ldi r16, HIGH(TASK3)
    sts TASK3_STACK_BEGIN-1, r16
;    
;program counter initialization for ADDITIONAL TASK
;WANT TO ADD MORE TASKS? :-)
;
;  ADD THE CODE HERE ,AS ABOVE WITH NEW TASK ADDRESS
;  ALSO DON'T FORGET TO UPDATE THE TASKX_STACK_BEGIN & TASK NUMBER
;  Also don't forget about the RAM capacity.. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
;-------------STARTUP END-------------------------------------;
;THE ABOVE CODE WILL NOT REPEAT ANY MORE UNTIL A RESET HAPPENS
;-------------------------------------------------------------;
    sei                     ;ENABLE GLOBAL INTERUPT
    rjmp TASK1              ;JUMP TO FIRST TASK AND THE REAL GAME BEGINS ;-)
;
;
;---------------------------------------------------------------------
;TASK 1 TO 3    
;Pls read this:
;All the example tasks are almost similar except TASK1. Each task is to control each 
;bit of PORTD, it toggle each bits and the delay of toggling is different 
;on each task. All the delay related registers are common to all tasks.
;This shows significance of the backup and restore of the cpu registers
;and status register while context switching.. We can see the LED 
;blinkings on each bit of PORTD is independent... Each one is 
;blinking at it's own delay and is not affected by any other, remember
;each one is an independent task and is continuously switching from 
;1 to 3 and the the cycle repeats...
;---------------------------------------------------------------------
;
;;;;;TASK -1;;;;;;SPECIAL PWM TASK (COULD OBSERVE IT ON LED);;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; LED on PD4   
TASK1:
    ldi r16, 255
    out DDRD, r16
    clr r23
while11:
    cpi r23,255
    brne increment
    dec r25
    rjmp skip_inc
increment:
    inc r25
skip_inc:
    cpi r25, 0
    brne next1
    com r23
next1:
    cpi r25, 255
    brne ll
    com r23
ll:
    rcall pwm
    dec r24
    lsr r24
    nop
    nop
    nop
    brne ll
    rjmp while11
pwm:
    push r25
    sbi PORTD, PD4
pwml1:
    dec r25
    brne pwml1
    pop r25
    push r25
    com r25
    cbi PORTD, PD4
pwml2:
    dec r25
    brne pwml2
    pop r25
    ret
;   
;;;;;TASK -2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LED on PD6    
TASK2:
    ldi r16, 255
    out DDRD, r16
while12:
    ldi R17,1<<PD6
    IN r16, PIND
    EOR r16,R17
    out PORTD,r16
    RCALL delay12
    rjmp while12    
;
delay12:
    ldi r25,100
l12:
    ldi r24,100
l22:
    ldi r23,20
l32:
    dec r23
    brne l32
    dec r24
    brne l22
    dec r25
    brne l12
    ret
;    
;;;;TASK -3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; LED on PD5   
TASK3:
    ldi r16, 255
    out DDRD, r16
while13:
    ldi R17,1<<PD5
    IN r16, PIND
    EOR r16,R17
    out PORTD,r16
    RCALL delay13
    rjmp while13    
;
delay13:
    ldi r25,255
l13:
    ldi r24,255
l23:
    ldi r23,15
l33:
    dec r23
    brne l33
    dec r24
    brne l23
    dec r25
    brne l13
    ret
;    
;--------------------------TASK END----------------------------------------;
;I S R  routine
;The scheduling has 6 basic steps:
; 1. Save the context of current task
; 2. Back up the stack pointer of current task in the kernel space
; 3. Decrement corresponding task timer variable (here not used)
; 4. Change to next task
; 5. Load the stack pointer of the next task from kernel space
; 6. Restore the context of the next task
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;THIS IS THE MOST IMPORTANT PART OF THIS PROGRAM:      
;IT BACKUP THE CURRENT STACK POINTER IN THE SP BACKUP TABLE AND TAKES THE NEXT TASK'S STACKPOINTER
;FROM THE SAME TABLE AND LOAD IT TO THE STACK POINTER.
;ALSO IT BACKUP AND RESTORE ALL THE REGISTERS  AND THE STATUS_REGISTER SO THAT THE PAUSED TASK COULD BE 
;RESUMED FROM IT'S PAUSED STATE WITHOUT ANY CHANGE IN THE CPU REGISTERS AND STATUS REGISTER...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
context_switch: 
;pushing all registers for the current task
; PC is pushed first automaticaly when interrupt occurs
    push r31
    push r30
    push r29
    push r28
    push r27
    push r26
    push r25
    push r24
    push r23
    push r22
    push r21
    push r20
    push r19
    push r18
    push r17
    push r16
	;pushing status register
    in r16, SREG
    push r16            
;-------CONTEXT SWITCHING -------------------;
    lds r16, TASK_INDEX  ; current task
    ldi r30, low(SP_BACKUP_BASE)
    clr r31
    
    sub r30,r16  ; get current task location in stack pointer backup table

    in r17, SPL   ; save SP for current task
    st Z, r17
    
    inc r16     ; Next task
    cpi r16, TOTAL_TASK  ; all tasks finished?
    brne SKIP1    ; No, continue
    ldi r30, low(SP_BACKUP_BASE)  ; Yes, point to the BASE of SP BACKUP table
    ; clr r31  ; already cleared befor
    
    clr r16    ; task = first one
    sts TASK_INDEX, r16
    ld r17, Z   ; load SP for first task
    rjmp SKIP2    
SKIP1:
    sts TASK_INDEX,r16   ; save index of next task
    ld r17, -Z  ; and load SP for it
SKIP2:
    out SPL,r17   ; restore SP with the value loaded befor in r17
    
;-----NOW WE GOT THE NEW STACK POINTER, SO THE TASK IS SWITCHED!-------;
; 
;the next process is to restore the status register and 
;all the cpu registers as it's previous state for the selected task....
    ; first restore status_reg
    pop r16
    out SREG, r16
    ; then GPRs
    pop r16
    pop r17
    pop r18
    pop r19
    pop r20
    pop r21
    pop r22
    pop r23
    pop r24
    pop r25
    pop r26
    pop r27
    pop r28
    pop r29
    pop r30
    pop r31
    ; finally restore PC
    reti                     ;and  go to next task to continue it until
                             ;next interrupt occurs
