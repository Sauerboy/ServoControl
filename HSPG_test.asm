; Infinite loop where the customers program can be written
; Every 10 is 1 ms pulse exp. 15 is 1.5 ms pulse for zero position
ORG 0
Loop:
	LOADI 90
	CALL DegreeTurn
DONE:
	JUMP DONE

; @AC should contain the amount of degrees user wants to turn with respect to origin
; -90 is clockwise max, 90 is counterclockwise max
; exp. 45 degrees is (2.5 + 1.5)/2 = 2ms pulse. When user inputs 45 degrees, do ((degrees/90) + 1.5 ms) * 10 = pulse
; @return the pulse in ms should be in AC once returned
DegreeTurn:
	;can be more accurate when dividing: need to actaully divide by 9
	;SHIFT -3  ; Divide by 8   180/8 = 22.5 -> 22 ->(Safe pulse) 20 which is ok
    CALL DIVIDE_NINE
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
	LOADI 20
    OUT Servo
    Return
    
 SetMid:
 	LOADI 10
    OUT Servo
    Return
; @AC should contain the desired ms pulse to turn to
; Sets pulse to input * 10 exp. 2.5 is in AC, so 25 should be sent to servo
; @return the pulse in ms should be in AC once returned
msTurn:


bounce:


ACbinarySound:

; Divide by 9 function
DIVIDE_NINE:
	STORE   DIVIDEND
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
ORG 30
Nine: DW 9
QUOTIENT: DW 0
DIVIDEND: DW 0

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Servo:	   EQU &H30
