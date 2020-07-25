	.include "input.asm"
	;.include "render.asm"
	.include "game.asm"
NMI:
	; NOTE - We're destroying registers
	;  Might want to push them on the
	;  stack and restore when done.
	LDA #$00
	STA $2003
	LDA #$02
	STA $4014                  ; Init DMA transfer of $0200 to PPU Internal OAM memory

	;JSR INPUT_READ_CTRL_1

	;JSR UPDATE_GAME

	;JSR RENDER_BG

	LDA #%10010000             ; Genrale NMI Interrupts on vblank, sprite pat tab 0, bg pat tab 1
	STA $2000

	LDA #%00011110             ; enable sprites, enable bg
	STA $2001

	LDA #$00
	STA $2005                  ; Horizontal scroll pos = 0
	STA $2005                  ; Vertical scroll pos = 0

	RTI                        ; Return from Interrupt	
