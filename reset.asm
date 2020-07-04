	SEI                        ; Disable IRQs
	CLD                        ; Disable Decimal mode (for comp with 6502 -- NES doesn't have decimal mode.
	LDX #$40
	STX $4017                  ; 40 sets bit 6 of $4017 -> if set, the frame interrupt flag is cleared.

	TSX                        ; Store stack pointer in X
	INX                        ; Inc X, should be 0 apparently.

	STX $2000                  ; Disable NMI Interrupt
	STX $2001                  ; Disable rendering
	STX $4010                  ; Disable DMC IRQs

vblankwait_1:
	BIT $2002                  ; Bit 7 of $2002: 0 not in vblank, 1 otherwise.  BIT takes bit 7 -> SR(N)
	BPL vblankwait_1           ; if SR bit N is 0, branch.

clrmem:                      ; This clears address $0000 to $0800
	LDA #$00
	STA $0000, x
	STA $0100, x
	STA $0200, x
	STA $0400, x
	STA $0500, x
	STA $0600, x
	STA $0700, x
	LDA #$FE
	STA $0300, x
	INX
	BNE clrmem                 ; When X will have carried over, 0 will be set.

vblankwait_2:                ; Second wait for vblank, PPU is ready after this
	BIT $2002
	BPL vblankwait_2

