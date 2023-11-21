; Infinite loop where the customers program can be written
; Every value inputed to servo must be scaled by 8/9 exp. 180 *(8/9) = 160. We out 160 to servo to get 180 degree turn
ORG 0
Loop:
DEMO1: ;Show basic functionality with switches
    IN Switches
    OUT Servo
    OUT LEDs
    AND BitmaskLast
    JZERO DEMO1
DEMO2: ;Show precision degree turns within assmebly
	; ZERO MID MAX
	CALL SetZero
    CALL WaitInput1
    CALL SetMid
    CALL WaitInput0
    CALL SetMax
    CALL WaitInput1
    CALL SetZero
    CALL WaitInput0
    ; EXACT DEGREES: 10 15 20 30 45 60
    LOADI 10
    CALL DegreeTurn
    CALL WaitInput1
    LOADI 15
    CALL DegreeTurn
    CALL WaitInput0
    LOADI 20
    CALL DegreeTurn
    CALL WaitInput1
    LOADI 30
    CALL DegreeTurn
    CALL WaitInput0
    LOADI 45
    CALL DegreeTurn
    CALL WaitInput1
    LOADI 60
    CALL DegreeTurn
    CALL WaitInput0
    
DEMO3: ; Demonstrate Sprinkler Mode
	LOADI 6
    CALL Sprinkler
	CALL WaitInput1

DEMO4: ; Demonstrate Applications: FAN
	LOADI 6
    CALL Bounce
    CALL WaitInput0
DONE:
	IN Switches
    AND BitmaskFirst4
    STORE x
    ADDI -8
    JZERO DEMO4
    LOAD x
    ADDI -4
    JZERO DEMO3
    LOAD x
    ADDI -2
    JZERO DEMO2
    LOAD x
    ADDI -1
    JZERO DEMO1
	JUMP DONE

; @AC should contain the amount of degrees user wants to turn with respect to origin
DegreeTurn:
    OUT Hex0
	CALL Scale
	OUT Servo
    Return
	
; @AC dont care
; Sets pulse to 0.5ms
; @return the pulse in ms should be in AC once returned
SetZero:
	LOADI 0
    CALL DegreeTurn
    Return
; @AC dont care
; Sets pulse to 2.5ms
; @return the pulse in ms should be in AC once returned
SetMax:
	LOADI 180
    CALL DegreeTurn
    OUT Servo
    Return
    
 SetMid:
 	LOADI 90
    CALL DegreeTurn
    Return

Bounce:
	STORE BounceCount
	CALL SetMax
    CALL Delay
    CALL SetZero
    CALL Delay
    LOAD BounceCount
    SUB  One
    STORE BounceCount
    JPOS Bounce
    RETURN
    
 	
Sprinkler:
	STORE BounceCount
    LOADI 0
    STORE SprinklerV
    CALL SprinklerPOS
    CALL SprinklerNEG
    LOAD BounceCount
    SUB  One
    STORE BounceCount
    JPOS Sprinkler
    RETURN
    
SprinklerPOS:
    LOAD SprinklerV
    ADDI 16
    STORE SprinklerV
    CALL DegreeTurn
    CALL Delay
    LOAD SprinklerV
    ADDI -8
    STORE SprinklerV
    CALL DegreeTurn
    CALL Delay
    LOAD SprinklerV
    SUB MAX
    JNEG SprinklerPOS
    RETURN

SprinklerNEG:
	LOAD SprinklerV
    ADDI -16
    STORE SprinklerV
    CALL DegreeTurn
    CALL Delay
    LOAD SprinklerV
    ADDI 8
    STORE SprinklerV
    CALL DegreeTurn
    CALL Delay
    LOAD SprinklerV
    JPOS SprinklerNEG
    RETURN
    
RCturn: ; Turn while centered in middle. Switch inputs as turns
	CALL SetMid
    
WindShieldWiper: ;Speed up towards middle, slow down near end, more advanced bounce and sprinkler
    
    
    
WaitInput1:
	IN Switches
    AND BitmaskLast
    JZERO WaitInput1
    JNEG WaitInput1
    RETURN
    
WaitInput0:
	IN Switches
    AND BitmaskLast
    JPOS WaitInput0
    JNEG WaitInput0
    RETURN
    

Delay:
	OUT    Timer
WaitingLoop:
	IN     Timer
	ADDI   -2
	JNEG   WaitingLoop
	RETURN
    
    
    
DegreeTurnS:
	CALL Scale
    
    
SpeedDelay:
	OUT    Timer
SpeedWait:
   	IN     Timer
	SUB Speed
	JNEG   SpeedWait
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
ORG 200
Nine: DW 9
QUOTIENT: DW 0
DIVIDEND: DW 0
Value: DW 0
BitmaskFirst4: DW  &H000F
Bitmask1: DW  &H0001
Bitmask2: DW  &H0002
Bitmask3: DW  &H0004
Bitmask4: DW  &H0008
BitmaskLast: DW &H0200
Input: DW 0
BounceCount: DW 0
One: DW 1
Speed: DW 0
MAX: DW 200
MIN: DW 0
SprinklerV: DW 0
x: DW 0



; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Servo:	   EQU &H30
