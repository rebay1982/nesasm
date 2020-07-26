NMI:

; Backup registers
	PHA
	TXA
	PHA
	TYA
	PHA

	LDA #$00
	STA $2001                  ; Disable rendering
	STA $2003
	LDA #$02
	STA $4014                  ; Init DMA transfer of $0200 to PPU Internal OAM memory

;draw bg if needed
	LDA request_draw
	BEQ draw_complete

	JSR DRAW_BG
	DEC request_draw

draw_complete:

	LDA #%00011110             ; enable sprites, enable bg
	STA $2001

	LDA #$00
	STA $2005                  ; Horizontal scroll pos = 0
	STA $2005                  ; Vertical scroll pos = 0

	LDA #$00
	STA sleep 

; Restore registers
	PLA
	TAY
	PLA
	TAX
	PLA

	RTI                        ; Return from Interrupt

; byte 0 = length
; byte 1 = (HI) PPU memory destination
; byte 2 = (LO) PPU memory destination
; byte 3 = data
;
; if byte 0 = 0; stop
DRAW_BG:
	LDX #$00

draw_bg_cmd_loop:
	LDY bg_draw_buffer, x
	BEQ exit_draw_bg
	INX

	BIT $2002
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

	JMP draw_bg_cmd_loop

exit_draw_bg:
	RTS

