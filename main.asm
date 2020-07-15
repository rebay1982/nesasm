	.inesprg 1                 ; 1x 16KB bank of PRG code
	.ineschr 1                 ; 1x 8KB bank of CHR data
	.inesmap 0                 ; mapper 0 = NROM, no bank swapping
	.inesmir 1                 ; background mirroring (ignore for now)


	.rsset $0000               ; Start data at memory address 0.
score_1 .rs 1
score_2 .rs 1
buttons_1 .rs 1              ; Buttons for controller 1.
buttons_2 .rs 2              ; Buttons for controller 2.


;=============================
; PRG BANK 0
;=============================
	.bank 0
	.org $C000
	.include "nmi.asm"
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

;clr_bg_nt:
;	LDA $2002                  ; Reset hi/lo pair for $2006 register.
;	LDA #$20
;	STA $2006
;	LDA #$00
;	STA $2006
;
;	LDY	#$00
;clr_bg_nt_loop_y:
;	LDX #$00
;clr_bg_nt_loop_x:
;	LDA #$24
;	STA $2007
;	INX
;	CPX #$FF
;	BNE clr_bg_nt_loop_x
;
;	INY
;	CPY #$04
;	BNE clr_bg_nt_loop_y

; Write title screen.	
setup_bg_nametable:
	LDA $2002                  ; Latch and reset hi/lo pairs for $2006 register.
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006                  ; Write to $2000, where the BG nametable starts.

	LDX #$00
setup_bg_nametable_loop:
	LDA bg_nametable_data, x
	STA $2007
	INX
	CPX #$20                   ; 128 bytes.
	BNE setup_bg_nametable_loop

setup_bg_attr:
	LDA $2002
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006
	
	LDX #$00
setup_bg_attr_loop:
	LDA bg_attr_data, x
	STA $2007
	INX
	CPX #$08
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
	.db $22, $29, $1A, $0F     ;background palette data
	.db $22, $36, $17, $0F
	.db $22, $30, $21, $0F
	.db $22, $27, $17, $0F
	.db $22, $1C, $15, $14     ;sprite palette data 
	.db $22, $02, $38, $3C
	.db $22, $1C, $15, $14
	.db $22, $02, $38, $3C 

sprite_attr_data:
	.db $80, $32, $00, $80     ; Sprite 1
	.db $80, $33, $00, $88     ; Sprite 2
	.db $88, $34, $00, $80     ; Sprite 3
	.db $88, $35, $00, $88     ; Sprite 4

bg_nametable_data:
	.db $20, $0E, $15, $0C
	.db $18, $16, $0E, $24
	.db $20, $0E, $15, $0C
	.db $18, $16, $0E, $24
	.db $20, $0E, $15, $0C
	.db $18, $16, $0E, $24
	.db $20, $0E, $15, $0C
	.db $18, $16, $0E, $24     ; Row 1
	.db $20, $0E, $15, $0C
	.db $18, $16, $0E, $24
	.db $20, $0E, $15, $0C
	.db $18, $16, $0E, $24
	.db $20, $0E, $15, $0C
	.db $18, $16, $0E, $24
	.db $20, $0E, $15, $0C
	.db $18, $16, $0E, $24     ; Row 2 

bg_attr_data:
	.db %00000000
	.db %00010000
	.db %01010000
  .db %00010000
	.db %00000000
	.db %00000000
	.db %00000000
  .db %00110000

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
