; Infinite loop where the customers program can be written
; Every 10 is 1 ms pulse exp. 15 is 1.5 ms pulse for zero position
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
    
DONE:
	JUMP DONE

; @AC should contain the amount of degrees user wants to turn with respect to origin
DegreeTurn:
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
    OUT Servo
    Return
    
 SetMid:
 	LOADI 90
    OUT Servo
    Return

bounce:


ACbinarySound:

Delay:
	OUT    Timer
WaitingLoop:
	IN     Timer
	ADDI   -20 ; wait 2 seconds
	JNEG   WaitingLoop
	RETURN


; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Servo:	   EQU &H30