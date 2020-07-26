; File that contains all
; rendering subroutines.
CLR_BG:
; Clear title screen
	LDA $2002                  ; Reset hi/lo pair for $2006 register.
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006

	LDY	#$00
clr_bg_loop_y:
	LDX #$00
clr_bg_loop_x:
	LDA #$24
	STA $2007
	INX
	CPX #$FF
	BNE clr_bg_loop_x

	INY
	CPY #$04
	BNE clr_bg_loop_y

	RTS

RENDER_BG:
; Find out which screen to render
	CLC
	LDA	state
	LSR A
	BCS render_title
	LSR A
	BCS render_game
	LSR A
	BCS render_game_over
	
	RTS

render_title:
	LDX #$00
	LDA #$20
	STA bg_draw_buffer, x
	
	INX
	LDA #$21
	STA bg_draw_buffer, x

	INX
	LDA #$E0
	STA bg_draw_buffer, x

	LDY #$00
render_title_loop:
	INX
	LDA title_screen_data, y
	STA bg_draw_buffer, x
	INY
	CPY #$20                   ; 32 bytes.
	BNE render_title_loop

	INX
	LDA #$00
	STA bg_draw_buffer, x      ; End draw buffer.
	RTS

render_game:

	RTS

render_game_over:

	RTS
