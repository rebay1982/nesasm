	; NOTE - We're destroying registers
	;  Might want to push them on the
	;  stack and restore when done.
	.include "input.asm"       ; Check input.

	LDA #$00
	STA $2003
	LDA #$02
	STA $4014                  ; Init DMA transfer of $0200 to PPU Internal OAM memory

	RTI                        ; Return from Interrupt	
