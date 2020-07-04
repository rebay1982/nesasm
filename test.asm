	.inesprg 1                 ; 1x 16KB bank of PRG code
	.ineschr 1                 ; 1x 8KB bank of CHR data
	.inesmap 0                 ; mapper 0 = NROM, no bank swapping
	.inesmir 1                 ; background mirroring (ignore for now)


;=============================
; PGR BANK 0
;=============================
	.bank 0
	.org $C000
nmi:
	.include "nmi.asm"

reset:
	.include "reset.asm"


main:

; This code sets up the PPU's base memory to the background palette
setup_palettes:
	LDA $2002                  ; This read actually resets write pair for $2005 and $2006 registers.
	LDA #$3F
	STA $2006
	LDA #$00
	STA $2006

	LDX #$00                   ; Load all palette data
init_palette_loop:
	LDA palette_data, x
	STA $2007
	INX
	CPX #$20                   ; Check if X == 32
	BNE init_palette_loop

; Palette setup complete, setup sprite data.
	LDA #$80                   ; To be used for mid screen (x/y)
	STA $0200                  ; Y position	
	STA $0203                  ; X position

	LDA #$00
	STA $0201                  ; Use tile 0
	STA $0202                  ; Use pal 0, in front of BG, no hor or vert flip.
	
	LDA #$80                   ; Genrale NMI Interrupts on vblank
	STA $2000

	LDA #$10                   ; No intensity (black BG), enable sprites
	STA $2001

forever:
	JMP forever


;=============================
; PGR BANK 1
;=============================
	.bank 1
	.org $E000
palette_data:
	.db $0F, $31, $32, $33     ;background palette data
	.db $0F, $35, $36, $37
  .db $0F, $39, $3A, $3B
  .db $0F, $3D, $3E, $0F
	.db $0F, $1C, $15, $14     ;sprite palette data 
	.db $0F, $02, $38, $3C
  .db $0F, $1C, $15, $14
	.db $0F, $02, $38, $3C 

	.org $FFFA
interrupt_vector:
	.dw nmi
	.dw reset
	.dw 0


;=============================
; CHR / DATA  BANK
;=============================
	.bank 2 
	.org $0000
	.include "data.asm"	
