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


;=============================
; RENDER_BG
;=============================
; Find a better way.  Code is
; duplicated only because the
; source address  is not in 
; the same spot.
;=============================
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

render_bg_exit:
	RTS



;=============================
; RENDER TITLE
;=============================
render_title:
	LDA #LOW(title_screen_data)
	STA params
	LDA #HIGH(title_screen_data)
	STA params+1
	LDA #$E0
	STA params+2
	LDA #$21
	STA params+3
	LDA #$20
	STA params+4
	LDA #$00
	STA params+5

	JSR RENDER_MULTI

	RTS

;=============================
; RENDER GAME
;=============================
render_game:

; Clear previous screen
	LDA #LOW(game_screen_data)
	STA params
	LDA #HIGH(game_screen_data)
	STA params+1
	LDA #$E0
	STA params+2
	LDA #$21
	STA params+3
	LDA #$20
	STA params+4
	LDA #$00
	STA params+5

	JSR RENDER_MULTI

; Render state screen return
	LDA #LOW(game_screen_data_2)
	STA params
	LDA #HIGH(game_screen_data_2)
	STA params+1
	LDA #$20
	STA params+2
	LDA #$20
	STA params+3
	LDA #$10
	STA params+4
	INC params+5

	JSR RENDER_MULTI

	RTS

render_game_over:

	RTS


;=============================
; RENDER MULTI
;============================-
; General purpose routine to
; write rendering requests at
; $0300 for the PPU to draw. 
;=============================
; params[0] Lo src address
; params[1] Hi src address
; params[2] Lo dst address
; params[3] Hi dst address
; params[4] Length
; params[5] Command #
;=============================
; Commands allow you to
;  prepare multiple rendering
;  commands in a single draw
;  call.
RENDER_MULTI:
; Find X
	LDX #$00
	LDY params+5

render_init_x_loop:
	CPY #$00
	BEQ render_init_x_done

	TXA
	CLC
	ADC bg_draw_buffer, x
	ADC #$03
	TAX
	DEY

	JMP render_init_x_loop

render_init_x_done:
	LDA params+4
	STA bg_draw_buffer, x

	INX
	LDA params+3
	STA bg_draw_buffer, x

	INX
	LDA params+2
	STA bg_draw_buffer, x

	LDY #$00
render_loop:
	INX
	LDA [params], y
	STA bg_draw_buffer, x
	INY
	CPY params+4
	BNE render_loop

	INX
	LDA #$00
	STA bg_draw_buffer, x      ; End draw buffer.

	RTS


;=============================
; DRAW_BG
;=============================
; byte 0 = length
; byte 1 = (HI) PPU memory destination
; byte 2 = (LO) PPU memory destination
; byte 3 = data
;
; When byte 0 -- 0x00, stop.
;=============================
DRAW_BG:
	LDX #$00

draw_bg_cmd_loop:
	LDY bg_draw_buffer, x
	BEQ exit_draw_bg
	INX

	BIT $2002                  ; Latch register $2006 on PPU
	LDA bg_draw_buffer, x
	STA $2006
	INX

	LDA bg_draw_buffer, x
	STA $2006

draw_bg_loop:
	INX

	LDA bg_draw_buffer, x
	STA $2007

	DEY
	BNE draw_bg_loop

	INX
	JMP draw_bg_cmd_loop

exit_draw_bg:
	RTS

