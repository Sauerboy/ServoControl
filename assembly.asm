; Infinite loop where the customers program can be written
; Every value inputed to servo must be scaled by 8/9 exp. 180 *(8/9) = 160. We out 160 to servo to get 180 degree turn
ORG 0
Loop:
    LOADI 90
    CALL DegreeTurn
    CALL Delay
    LOADI 180
    CALL DegreeTurn
    CALL Delay
    LOADI 0
    CALL DegreeTurn 
	CALL Delay
	JUMP Loop
DONE:
	JUMP DONE

; @AC should contain the amount of degrees user wants to turn with respect to origin
DegreeTurn:
	CALL Scale
	OUT Servo
    Return
	
; @AC dont care
; Sets pulse to 0.5ms
; @return the pulse in ms should be in AC once returned
SetZero:
	LOADI 0
    OUT Servo
    Return
; @AC dont care
; Sets pulse to 2.5ms
; @return the pulse in ms should be in AC once returned
SetMax:
	LOADI 180
    CALL Scale
    OUT Servo
    Return
    
 SetMid:
 	LOADI 90
    CALL Scale
    OUT Servo
    Return

bounce:


ACbinarySound:

Delay:
	OUT    Timer
WaitingLoop:
	IN     Timer
	ADDI   -60 ; wait 2 seconds
	JNEG   WaitingLoop
	RETURN
Scale:
	STORE Value
	SHIFT 3 ;x8
    CALL DIVIDE_NINE
    Return
    
; Divide by 9 function
DIVIDE_NINE:
	STORE   DIVIDEND
    	LOADI 0
    	STORE QUOTIENT
DIVIDE_LOOP:
    LOAD    DIVIDEND ; Load the dividend from memory
    SUB     Nine  ; Subtract the divisor (9) from the dividend
    STORE   DIVIDEND ; Store the updated dividend
    JNEG    DIVIDE_DONE ; If AC < 0, we are done

    LOAD    QUOTIENT ; Load the quotient from memory
    ADDI    1       ; Increment the quotient
    STORE   QUOTIENT ; Store the updated quotient
    JUMP    DIVIDE_LOOP ; Repeat the division loop

DIVIDE_DONE:
    LOAD    QUOTIENT ; Load the final quotient
    RETURN
    

; Constants
ORG 50
Nine: DW 9
QUOTIENT: DW 0
DIVIDEND: DW 0
Value: DW 0


; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Servo:	   EQU &H30
