	LDA #$00
	STA $2003
	LDA #$02
	STA $4014									 ; Init DMA transfer of $0200 to PPU Internal OAM memory

	RTI                        ; Return from Interrupt	
