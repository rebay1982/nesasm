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


