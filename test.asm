	.inesprg 1                 ; 1x 16KB bank of PRG code
	.ineschr 1                 ; 1x 8KB bank of CHR data
	.inesmap 0                 ; mapper 0 = NROM, no bank swapping
	.inesmir 1                 ; background mirroring (ignore for now)

	.bank 0
	.org $C000
nmi:
	.include "nmi.asm"

reset:
	.include "reset.asm"

main:
	LDX #$00
	LDY #$00
	
loop_blue:
	INX
	BNE loop_blue

	INY
	BNE loop_blue

	LDA #%10000000             ; Blue emphasis
	STA $2001

loop_green:
	INX
	BNE loop_green

	INY
	BNE loop_green

	LDA #%01000000             ; Green emphasis
	STA $2001

loop_red:
	INX
	BNE loop_red

	INY
 	BNE loop_red

	LDA #%00100000             ; Red emphasis
	STA $2001

	JMP main

	.bank 1
	.org $FFFA
interrupt_vector:
	.dw nmi
	.dw	reset
	.dw 0
