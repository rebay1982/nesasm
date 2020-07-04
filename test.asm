  .inesprg 1   ; 1x 16KB bank of PRG code
  .ineschr 1   ; 1x 8KB bank of CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring (ignore for now)

	.bank 0
	.org $C000
reset:
	.include "reset.asm"

main:
	LDA	#%10000000		; Bit 7 of PPU register at $2001 intensifies blue.
	STA $2001
	JMP main

nmi:
	.include "nmi.asm"
	

	.bank 1
	.org $FFFA
interrupt_vector:
	.dw nmi
	.dw	reset
	.dw 0
