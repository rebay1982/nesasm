	.inesprg 1                 ; 1x 16KB bank of PRG code
	.ineschr 1                 ; 1x 8KB bank of CHR data
	.inesmap 0                 ; mapper 0 = NROM, no bank swapping
	.inesmir 1                 ; background mirroring (ignore for now)

;=============================
; CONSTANTS
;============================
bg_draw_buffer = $0300
wall_top = $10               ; NTSC NES doesn't render the first 8pixel row to screen.
wall_bottom = $DF            ; 240 - 8, -8 (last 8 rows not shown on screen on NTSC NES)
wall_right = $F8             ; Decimal 248 (256 - 8) 
wall_left = $00


;=============================
; VARIABLES
;=============================
	.rsset $0000               ; Start data at memory address 0.
buttons_1 .rs 1              ; Buttons for controller 1.
buttons_2 .rs 1              ; Buttons for controller 2.
state .rs 1                  ; Contains the game state.
state_trans .rs 1            ; Indicates a state transition

sleep .rs 1                  ; Sleep state counter.
request_dma .rs 1            ; Request DMA transfer for sprites.
request_draw .rs 1           ; Request that the PPU draws during vblank.

ball_dir .rs 1               ; Defines in which direction the ball should be going.
                             ; Bit 0: 0 == up,   1 == down.
bounce_count_lo .rs 1        ; Lo byte of bounce count.
bounce_count_hi .rs 1        ; Hi byte of bounce count.

bounce_count_bcd .rs 5

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

setup_sprite_data:
	LDX #$00
setup_sprite_data_loop:
	LDA sprite_attr_data, x
	STA $0200, x
	INX
	CPX #$04
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
	BEQ loop_render_no_trans
	DEC state_trans

	JSR RENDER_BG
	INC request_draw           ; State changed, request a new draw
	JMP loop_sleep

loop_render_no_trans:
; If we're in the game state
; Render the bounce count
	LDA state
	AND #%00000010 
	BEQ loop_sleep

	JSR RENDER_COUNT
	INC request_draw

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
	.db $22, $20, $01, $00     ;background palette data
	.db $22, $20, $01, $00
	.db $22, $20, $01, $00
	.db $22, $20, $01, $00
	.db $22, $1C, $15, $14     ;sprite palette data
	.db $22, $02, $38, $3C
	.db $22, $1C, $15, $14
	.db $22, $02, $38, $3C 

sprite_attr_data:
	.db wall_top, $75, $00, wall_left     ; Sprite 1

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

game_screen_data_2:
	.db $0B, $18, $1E, $17
	.db $0C, $0E, $24, $28
	.db $24, $24, $24, $24
	.db $24, $24, $24, $24

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
