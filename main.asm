	.inesprg 1                 ; 1x 16KB bank of PRG code
	.ineschr 1                 ; 1x 8KB bank of CHR data
	.inesmap 0                 ; mapper 0 = NROM, no bank swapping
	.inesmir 1                 ; background mirroring (ignore for now)

; Memory already gets cleared here.
	.rsset $0000               ; Start data at memory address 0.
score_1 .rs 1
score_2 .rs 1
buttons_1 .rs 1              ; Buttons for controller 1.
buttons_2 .rs 2              ; Buttons for controller 2.
state .rs 1                  ; Contains the game state.

;=============================
; PRG BANK 0
;=============================
	.bank 0
	.org $C000
	.include "nmi.asm"
	.include "render.asm"
	.include "reset.asm"
MAIN:
	;;JSR RESET

	; Set state
	LDA #$01
	STA state

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

setup_bg_attr:
	LDA $2002
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006
	
	LDX #$00
	LDA #$00
setup_bg_attr_loop:
	STA $2007
	INX
	CPX #$40
	BNE setup_bg_attr_loop
	
	LDA #%10010000             ; Genrale NMI Interrupts on vblank, sprite pat tab 0, bg pat tab 1
	STA $2000

	LDA #%00011110             ; enable sprites, enable bg, left clip off.
	STA $2001


forever:
	JMP forever

;=============================
; PRG BANK 1
;=============================
	.bank 1
	.org $E000

palette_data:
	.db $0F, $20, $01, $00     ;background palette data
	.db $22, $20, $01, $00
	.db $22, $20, $01, $00
	.db $22, $20, $01, $00
	.db $0F, $1C, $15, $14     ;sprite palette data 
	.db $22, $02, $38, $3C
	.db $22, $1C, $15, $14
	.db $22, $02, $38, $3C 

sprite_attr_data:
	.db $80, $32, $00, $80     ; Sprite 1
	.db $80, $33, $00, $88     ; Sprite 2
	.db $88, $34, $00, $80     ; Sprite 3
	.db $88, $35, $00, $88     ; Sprite 4

title_screen_data:
	.db $24, $24, $24, $24
	.db $1B, $0E, $0B, $0A
	.db $22, $01, $09, $08
	.db $02, $24, $28, $24
	.db $19, $1B, $0E, $1C
	.db $1C, $24, $1C, $1D
	.db $0A, $1B, $1D, $2B
	.db $24, $24, $24, $24     ; Row 1

; Unused for now.
bg_attr_data:
	.db %00000000
	.db %00000000
	.db %00000000
  .db %00000000
	.db %00000000
	.db %00000000
	.db %00000000
  .db %00000000

	.org $FFFA
interrupt_vector:
	.dw NMI 
	.dw RESET 
	.dw 0

;=============================
; CHR / DATA  BANK
;=============================
	.bank 2 
	.org $0000
	.include "data.asm"	
