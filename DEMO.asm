; Main Program: Customized SCOMP API for various customer applications.
;				Implemented functions are as follows:
;               -- DegreeTurn:
;                   - Using a degree value stored in AC prior to CALL, 
;					  this function turns to the exact degree requested
;                   - Automatically displays value in decimal on Hex Display
;					- SetMax, SetZero, SetMid are subfunctions
;					- Scale preset to 8/9
;				-- Scale
;					- Scaling factor for the output to servo
;					- Due to manufacturing variability and indivudual servo differences,
;					  this scaling factor is presented to allow the customer to account for those differences
;					- Every value inputed to servo must be scaled by 8/9 exp. 180 *(8/9) = 160. We out 160 to servo to get 180 degree turn
;				-- Sprinkler
;					- Autonomous function that to behave like a sprinkler by moving forward 16 degrees
;					  then moving back 8 degrees
;				-- Bounce
;					- Autonomous function that controls the speed bounce functionality of the Servo
;					- Input speed into AC, and the servo will bounce smoothly at that speed.
;
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
	LOADI 32
    CALL Bounce
    CALL Delay
    LOADI 64
    CALL Bounce
    CALL Delay
    LOADI 128
    CALL Bounce
    CALL Delay
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
    STORE DECIMAL_VAL
	STORE CONVERT
    LOADI -1
    STORE INCREMENT
    LOADI 0
    STORE RESULT
	CALL DISPLAY_CONV
	OUT Hex0

	LOAD DECIMAL_VAL
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

Bounce: ; Put speed in AC, out the speed: Larger numnber = faster
		; Range is 8 bits or 0-128
    SHIFT 1
	STORE Speed
    OR Bitmask1
    OUT Servo
    RETURN
    
; Spinkler function
; @AC put number of desired cycles
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
	ADDI   -50
	JNEG   WaitingLoop
	RETURN
    
    
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

; DISPLAY LOGIC
DISPLAY_CONV:
    LOAD INCREMENT
    ADDI 1
    STORE INCREMENT

    LOAD CONVERT
    STORE MOD1
    CALL MODULO

    CALL SHIFT16
    LOAD RESULT
    ADD SHIFTVAL
    STORE RESULT

    LOAD CONVERT
    CALL DIVIDE_TEN
    STORE CONVERT

    JZERO END_CONV
    JUMP DISPLAY_CONV

END_CONV:
	LOAD RESULT
    RETURN

DIVIDE_TEN:
	STORE DIVIDEND
    LOADI 10
    STORE DIVISOR
    LOADI 0
    STORE QUOTIENT
    CALL DIVIDE_LOOP
    RETURN


;MOD1 % 10
MODULO:
    LOAD MOD1
    ADDI -10
    STORE MOD1
    JNEG MODULO_DONE
    JZERO MODULO_ZERO
    JUMP MODULO
MODULO_DONE:
	LOAD MOD1
    ADDI 10
    STORE MOD2
    RETURN
MODULO_ZERO:
	LOADI 0
    STORE MOD2
    RETURN

MULT:
	LOAD PROD1
    ADDI -1
    STORE PROD1

    JZERO MULT_DONE
    JNEG MULT_ZERO

    LOAD PROD3
    ADD PROD2
    STORE PROD3

    JUMP MULT
MULT_DONE:
	LOAD PROD3
    ADD PROD2
    STORE PROD3
    RETURN
MULT_ZERO:
	LOADI 0
   	STORE PROD3
    RETURN

SHIFT16:
    STORE SHIFTVAL
	LOAD INCREMENT
    STORE PROD1
    LOADI 4
    STORE PROD2
    LOADI 0
    STORE PROD3
    CALL MULT
    CALL SHIFT2LOOP
    RETURN

SHIFT2LOOP:
	LOAD PROD3
    ADDI -1
    STORE PROD3
    JNEG SHIFT2LOOP_END

    LOAD SHIFTVAL
	SHIFT 1
    STORE SHIFTVAL
    LOAD PROD2

    JPOS SHIFT2LOOP

    RETURN

SHIFT2LOOP_END:
	RETURN






; Constants
ORG 300
DIVISOR: DW 0
QUOTIENT: DW 0
DIVIDEND: DW 0
Value: DW 0
Nine: DW 9
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
MOD1: DW 0
MOD2: DW 0
MOD3: DW 0
PROD1: DW 0
PROD2: DW 0
PROD3: DW 0
CONVERT: DW 0
RESULT: DW 0
SHIFTVAL: DW 1
INCREMENT: DW -1
DECIMAL_VAL: DW 0



; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Servo:	   EQU &H30
