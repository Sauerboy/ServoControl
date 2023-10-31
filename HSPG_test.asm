; An empty asm file ...

ORG 0

Loop:
IN Switches
OUT LEDs
OUT Servo
JUMP Loop

	
; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Servo:	   EQU &H30
