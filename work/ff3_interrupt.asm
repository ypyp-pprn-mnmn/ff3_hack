; ff3_interrupt.asm
;
; description:
;	replaces NMI/IQA related codes
;
; version:
;	0.1.0
;======================================================================================================
ff3_interrupt_begin:
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $3f,$ff00,$ff03
dispatch_await_nmi:
	jmp await_nmi_by_set_handler
	VERIFY_PC $ff03
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $3f,$ff2a,$ff36
;;$3f:ff2a nmi_handler_01
disable_handler_and_return_from_nmi:
	lda $2002
	lda #$40	;RTI
	sta pNmiHandler-1
	pla
	pla
	pla
	rts
	VERIFY_PC $ff36
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $3f,$ff36,$ff48
;;$3f:ff36 setNmiHandlerTo_ff2a_andWaitNmi
;;callers: dispatch_await_nmi ($3f:ff00)
await_nmi_by_set_handler:
.copy_thunk:
	;;to prevent handler from jump in invalid address
	;;the code byte should be written after address has completely updated
	lda #LOW(disable_handler_and_return_from_nmi)
	sta pNmiHandler
	lda #HIGH(disable_handler_and_return_from_nmi)
	sta pNmiHandler+1
	lda #$4c	;JMP
	sta pNmiHandler-1
.await_nmi:
	jmp .await_nmi
.thunk_template:
	;jmp disable_handler_and_return_from_nmi
	VERIFY_PC $ff48
;------------------------------------------------------------------------------------------------------
	;RESTORE_PC ff3_field_window_begin