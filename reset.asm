vblankwait:                  ; Second wait for vblank, PPU is ready after this
	BIT $2002                  ; Bit 7 of $2002: 0 not in vblank, 1 otherwise.  BIT takes bit 7 -> SR(N)
	BPL vblankwait             ; if SR bit N is 0, branch.
	RTS

; Unless we save and restore 
; the stack pointer and memory
; to its previous state, this 
; cannot be used as a 
; subroutine because it 
; destroys the stack memory at
; $0100 
RESET:
	SEI                        ; Disable IRQs
	CLD                        ; Disable Decimal mode (for comp with 6502 -- NES doesn't have decimal mode.
	LDX #$40
	STX $4017                  ; 40 sets bit 6 of $4017 -> if set, the frame interrupt flag is cleared.
	
	LDX #$FF
	TXS                        ; Store X into stack pointer
	INX                        ; X == 0 now. 

	STX $2000                  ; Disable NMI Interrupt
	STX $2001                  ; Disable rendering
	STX $4010                  ; Disable DMC IRQs

	JSR vblankwait

clrmem:                      ; This clears address $0000 to $0800
	LDA #$00
	STA $0000, x
	STA $0100, x               ; This is the stack space.
	STA $0300, x
	STA $0400, x
	STA $0500, x
	STA $0600, x
	STA $0700, x
	LDA #$FE
	STA $0200, x               ; Move all sprites off screen
	INX
	BNE clrmem                 ; When X will have carried over, 0 will be set.

	JSR vblankwait

	;RTS                       ; See comment at the top of RESET label




