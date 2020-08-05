UPDATE_GAME:

; Find out which state to update.
	CLC	
	LDA	state
	LSR A
	BCS update_title
	LSR A
	BCS update_game
	
	RTS

update_title:
	LDA buttons_1
	AND #%00010000             ; Start button is bit 3
	BEQ update_title_return 

	ASL state                  ; C <- [76543210] <- 0
	INC state_trans

update_title_return:
	RTS	


update_game:


update_game_return:
	RTS
