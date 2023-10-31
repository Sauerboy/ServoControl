; Infinite loop where the customers program can be written
; Every 10 is 1 ms pulse exp. 15 is 1.5 ms pulse for zero position
ORG 0
Loop:
	IN Switches
	OUT LEDs
	OUT Servo
	JUMP Loop
JUMP 0
	
; @AC should contain the amount of degrees user wants to turn with respect to origin
; -90 is clockwise max, 90 is counterclockwise max
; exp. 45 degrees is (2.5 + 1.5)/2 = 2ms pulse. When user inputs 45 degrees, do ((degrees/90) + 1.5 ms) * 10 = pulse
; @return the pulse in ms should be in AC once returned
DegreeTurn:
	
; @AC dont care
; Sets pulse to 0.5ms
; @return the pulse in ms should be in AC once returned
SetZero:

; @AC dont care
; Sets pulse to 2.5ms
; @return the pulse in ms should be in AC once returned
SetMax:

; @AC should contain the desired ms pulse to turn to
; Sets pulse to input * 10 exp. 2.5 is in AC, so 25 should be sent to servo
; @return the pulse in ms should be in AC once returned
msTurn:


bounce:


ACbinarySound:

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Servo:	   EQU &H30
