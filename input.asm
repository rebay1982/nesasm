INPUT_READ_CTRL_1:
	LDA #$01
	STA $4016                  ; Need to write $01 and $00 to $4016 for controller to latch values
	LDA #$00
	STA $4016
	LDX #$08                   ; Read all 8 buttons.

read_ctrl_1_loop:
	LDA $4016
	LSR A                      ; BIT 0 of A -> Carry
	ROL buttons_1              ; Carry -> BIT 0 of buttons_1	
	DEX
	BNE read_ctrl_1_loop

	RTS                        ; Return to calling routine
