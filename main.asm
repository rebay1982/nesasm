	.inesprg 1                 ; 1x 16KB bank of PRG code
	.ineschr 1                 ; 1x 8KB bank of CHR data
	.inesmap 0                 ; mapper 0 = NROM, no bank swapping
	.inesmir 1                 ; background mirroring (ignore for now)


;=============================
; PRG BANK 0
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
setup_palettes_loop:
	LDA palette_data, x
	STA $2007
	INX
	CPX #$20                   ; Check if X == 32
	BNE setup_palettes_loop

setup_sprite_data:
	LDX #$00
setup_sprite_data_loop:
	LDA sprite_attr_data, x
	STA $0200, x
	INX
	CPX #$10
	BNE setup_sprite_data_loop
	
	LDA #$80                   ; Genrale NMI Interrupts on vblank
	STA $2000

	LDA #$10                   ; No intensity (black BG), enable sprites
	STA $2001

forever:

	JMP forever


;=============================
; PRG BANK 1
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

sprite_attr_data:
	.db $80, $32, $00, $80     ; Sprite 1
	.db $80, $33, $00, $88     ; Sprite 2
	.db $88, $34, $00, $80     ; Sprite 3
	.db $88, $35, $00, $88     ; Sprite 4

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
