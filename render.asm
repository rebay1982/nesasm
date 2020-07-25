; File that contains all
; rendering subroutines.
RENDER_BG:
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
	LDA $2002                  ; Latch and reset hi/lo pairs for $2006 register.
	LDA #$21
	STA $2006
	LDA #$E0
	STA $2006                  ; Write to $2000, where the BG nametable starts.

	LDX #$00
render_title_loop:
	LDA title_screen_data, x
	STA $2007
	INX
	CPX #$20                   ; 32 bytes.
	BNE render_title_loop

	RTS

render_game:

	RTS


render_game_over:

	RTS
