UPDATE_GAME:

; Find out which state to update.
	CLC	
	LDA	state
	LSR A
	BCS update_title
	LSR A
	BCS update_game
	
	RTS

update_title:
	LDA buttons_1
	AND #%00010000             ; Start button is bit 3
	BEQ update_title_return 

	ASL state                  ; C <- [76543210] <- 0
	INC state_trans

update_title_return:
	RTS	


update_game:

	JSR input_ball_dir

	JSR update_ball_dir

	JSR move_ball

update_game_return:
	RTS



;=============================
; update_ball_dir
;=============================
; Routine to update the ball's
; direction based on its
; current position.
;=============================
; When we hit screen top, set
;   bit 0 of ball_dir to 1.
; When we hit screen bottom,
;  set bit 0 of ball_dir to 0.
; When we hit screen left, set
;  bit 1 if ball_dir to 1.
; When we hit screen right,
;  set bit 1 of ball_dir to 0.
;=============================
; + Performance could be
;   better if registers were
;   better used instead of
;   always loading into
;   accumulator.
; + Use parameters instead
;   of $0200 and $0203
;=============================
update_ball_dir:
check_top:
	LDA $0200
	CMP #wall_top
	BNE check_bottom

	LDA ball_dir
	ORA #$01
	STA ball_dir

	JSR inc_bounce_count_bcd

	JMP check_left             ; If top is eq to 0, no need to check bottom.

check_bottom:
	CMP #wall_bottom
	BNE check_left

	LDA ball_dir
	AND #%11111110
	STA ball_dir

	JSR inc_bounce_count_bcd

check_left:
	LDA $0203                  ; X pos is sprite attribute data's 4th byte. (byte 3)
	CMP #wall_left
	BNE check_right

	LDA ball_dir
	ORA #$02
	STA ball_dir

	JSR inc_bounce_count_bcd

	JMP check_done

check_right:
	CMP #wall_right
	BNE check_done

	LDA ball_dir
	AND #%11111101
	STA ball_dir

	JSR inc_bounce_count_bcd

check_done:
	RTS

;=============================
; input_ball_dir
;=============================
; Routine that changes the
; ball's direction based
; on input. 
;=============================
input_ball_dir:
input_ball_up:
	LDA buttons_1
	AND #$08                   ; Bit 3 == UP
	BEQ input_ball_down

	LDA ball_dir
	AND #%11111110
	STA ball_dir	

input_ball_down:
	LDA buttons_1
	AND #$04                   ; Bit 2 == DOWN
	BEQ input_ball_left

	LDA ball_dir
	ORA #$01
	STA ball_dir

input_ball_left:
	LDA buttons_1
	AND #$02                   ; Bit 1 == LEFT
	BEQ input_ball_right

	LDA ball_dir
	AND #%11111101
	STA ball_dir

input_ball_right:
	LDA buttons_1
	AND #$01                   ; Bit 0 == RIGHT
	BEQ input_ball_dir_done

	LDA ball_dir
	ORA #$02
	STA ball_dir

input_ball_dir_done:
	RTS


;=============================
; move_ball
;=============================
; Routine dedicated to move
; the first sprite  based on
; ball_dir.
;=============================
; Can be made better by
; making $0200 and $0203 
; parameters.
;=============================
move_ball:
move_horizontal:
	LDA ball_dir
	AND #%00000010

	BNE move_right
move_left:
	DEC $0203                  ; byte 3 is X position.
	JMP move_vertical

move_right:
	INC $0203                  ; byte 3 is X position.

move_vertical:
	LDA ball_dir
	AND #%00000001

	BNE move_down
move_up:
	DEC $0200                  ; byte 0 is Y position.
	JMP move_ball_return

move_down:
	INC $0200                  ; byte 0 is Y position.

move_ball_return:
	RTS



;=============================
; inc_bounce_count
;=============================
; Routine to count (16bits) 
;  the number of times the 
;  ball nounces.
;=============================
; Accumulator is saved.
; CPU Status is saved.
;=============================
inc_bounce_count:
	PHA
	PHP

	LDA bounce_count_lo
	CLC
	ADC #$01
	STA bounce_count_lo
	LDA bounce_count_hi
	ADC #$00
	STA bounce_count_hi

	PLP
	PLA

	RTS


;=============================
; inc_bounce_count_bcd
;=============================
inc_bounce_count_bcd:
	PHA
	TXA
	PHA
	PHP

	LDX #$04

inc_bounce_count_bcd_loop:
	INC bounce_count_bcd, x
	LDA bounce_count_bcd, x
	CMP #$0A
	BNE inc_bounce_count_bcd_done

	LDA #$00
	STA bounce_count_bcd, x
	DEX                        ; Really? This doesn't affect the V status.
	TXA
	CMP #$FF
	BNE inc_bounce_count_bcd_loop 

inc_bounce_count_bcd_done:
	PLP
	PLA
	TAX
	PLA

	RTS

