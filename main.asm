	.inesprg 1                 ; 1x 16KB bank of PRG code
	.ineschr 1                 ; 1x 8KB bank of CHR data
	.inesmap 0                 ; mapper 0 = NROM, no bank swapping
	.inesmir 1                 ; background mirroring (ignore for now)

bg_draw_buffer = $0300

	.rsset $0000               ; Start data at memory address 0.
score_1 .rs 1
score_2 .rs 1
buttons_1 .rs 1              ; Buttons for controller 1.
buttons_2 .rs 2              ; Buttons for controller 2.
state .rs 1                  ; Contains the game state.
state_trans .rs 1            ; Indicates a state transition

sleep .rs 1                  ; Sleep state counter.
request_dma .rs 1            ; Request DMA transfer for sprites.
request_draw .rs 1           ; Request that the PPU draws during vblank.

sprite_pos_x .rs 1           ; Sprite X coordinate
sprite_pos_y .rs 1           ; Sprite Y coordinate

; This has to be in zero page
params .rs 32



;=============================
; PRG BANK 0
;=============================
	.bank 0
	.org $C000

	.include "input.asm"
	.include "render_bg.asm"
	.include "game.asm"
	.include "nmi.asm"
	.include "reset.asm"

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

;setup_sprite_data:
;	LDX #$00
;setup_sprite_data_loop:
;	LDA sprite_attr_data, x
;	STA $0200, x
;	INX
;	CPX #$04
;	BNE setup_sprite_data_loop

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


	JSR CLR_BG
	
	LDA #%10010000             ; Generate NMI Interrupts on vblank, sprite pat tab 0, bg pat tab 1
	STA $2000


;============================
; MAIN
;============================
MAIN:
; Init game state
	LDA #$01
	STA state

; Prepare the titlescreen background
	JSR RENDER_BG
	INC request_draw 

loop:

loop_input:
; Read Input
	JSR INPUT_READ_CTRL

loop_update:
; Update Game
	JSR UPDATE_GAME

loop_render:
; check if state transition happened.
	LDA state_trans
	BEQ loop_sleep
	DEC state_trans

	JSR RENDER_BG
	INC request_draw           ; State changed, request a new draw

loop_sleep:
	JSR SLEEP
	JMP loop



SLEEP:
	INC sleep
sleep_loop:
	LDA sleep
	BNE sleep_loop
	
	RTS


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
	.db $80, $75, $00, $80     ; Sprite 1

title_screen_data:
	.db $24, $24, $24, $24
	.db $1B, $0E, $0B, $0A
	.db $22, $01, $09, $08
	.db $02, $24, $28, $24
	.db $19, $1B, $0E, $1C
	.db $1C, $24, $1C, $1D
	.db $0A, $1B, $1D, $2B
	.db $24, $24, $24, $24     ; Row 1

game_screen_data:
	.db $24, $24, $24, $24
	.db $24, $24, $24, $24
	.db $24, $24, $24, $24
	.db $24, $24, $24, $24
	.db $24, $24, $24, $24
	.db $24, $24, $24, $24
	.db $24, $24, $24, $24
	.db $24, $24, $24, $24
;	.db $24, $24, $24, $24
;	.db $24, $24, $24, $24
;	.db $19, $15, $0A, $22
;	.db $24, $24, $24, $24
;	.db $24, $24, $24, $24
;	.db $10, $0A, $16, $0E
;	.db $24, $24, $24, $24
;	.db $24, $24, $24, $24     ; Row 1



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
