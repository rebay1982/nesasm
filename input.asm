	LDA #$01
	STA	$4016                  ; Need to write $01 and $00 to $4016 for controller to latch values
	LDA #$00
	STA $4016

; DO CTRL1
read_a:
	LDA $4016                  ; CTLR1, A
	AND #$01
	BEQ read_a_done
read_a_done:

read_b:
	LDA $4016                  ; CTLR1, B 
	AND #$01
	BEQ read_b_done
read_b_done:

read_select:
	LDA $4016                  ; CTLR1, Select
	AND #$01
	BEQ read_select_done
read_select_done:

read_start:
	LDA $4016                  ; CTLR1, Start
	AND #$01
	BEQ read_start_done
read_start_done:

read_up:
	LDA $4016                  ; CTLR1, Up
	AND #$01
	BEQ read_up_done

	LDX #$00
read_up_loop:
	LDA $0200, x
	SEC
	SBC #$02
	STA $0200, x
	INX
	INX
	INX
	INX
	CPX #$10	
	BNE read_up_loop
read_up_done:

read_down:
	LDA $4016                  ; CTLR1, Down
	AND #$01
	BEQ read_down_done

	LDX #$00
read_down_loop:
	LDA $0200, x
	CLC
	ADC #$02
	STA $0200, x
	INX
	INX
	INX
	INX
	CPX #$10	
	BNE read_down_loop
read_down_done:

read_left:
	LDA $4016                  ; CTLR1, Left
	AND #$01
	BEQ read_left_done

	LDX #$00
read_left_loop:
	LDA $0203, x
	SEC
	SBC #$02
	STA $0203, x
	INX
	INX
	INX
	INX
	CPX #$10	
	BNE read_left_loop
read_left_done:

read_right:
	LDA $4016                  ; CTLR1, Right
	AND #$01
	BEQ read_right_done

	LDX #$00
read_right_loop:
	LDA $0203, x
	CLC
	ADC #$02
	STA $0203, x
	INX
	INX
	INX
	INX
	CPX #$10	
	BNE read_right_loop
read_right_done:

