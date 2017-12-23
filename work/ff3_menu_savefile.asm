;; encoding: utf-8
;; ff3_menu_savefile.asm
;;
;;	re-implementation of logics around 'save' menu.
;;
;; version:
;;	0.1.0
;;=================================================================================================
__FF3_MENU_SAVEFILE_INCLUDED__
	.ifdef _FEATURE_DEFERRED_RENDERING

	INIT_PATCH_EX menu.savefile, $3d,$a9e1,$a9f9,$a9e1
;;# $3d:a9e1 menu.savefile.draw_file_summary
;;### args:
;;
;;#### in:
;;+	u8 A: higher byte of addres of the file (0x64, 0x68, 0x6c)
;;
;;#### out:
;;+	bool carry: is file available. where:
;;	+ 1 = available.
;;	+ 0 = unavailable. (therefore window hasn't drawn.)
;;
;;### callers:
;;+	`1E:A9AF:20 E1 A9  JSR menu.savefile.draw_summary` file1 @$3d:a9a0 menu.savefile.build_file_menu
;;+	`1E:A9BB:20 E1 A9  JSR menu.savefile.draw_summary` file2 @$3d:a9a0 menu.savefile.build_file_menu
;;+	`1E:A9C7:20 E1 A9  JSR menu.savefile.draw_summary` file3 @$3d:a9a0 menu.savefile.build_file_menu
menu.savefile.draw_file_summary:
    pha             ; A9E1 48
    lsr a       ; A9E2 4A
    lsr a       ; A9E3 4A
    and #$03    ; A9E4 29 03
    jsr $ae97   ; A9E6 20 97 AE
	pla	;;carry won't be affected.
    bcc .file_available   ; A9E9 90 03
    ;pla             ; A9EB 68
    ;clc             ; A9EC 18
    ;rts             ; A9ED 60
		jmp render_x.draw_empty_box
; ----------------------------------------------------------------------------
.file_available:
    ;pla             ; A9EE 68
    jsr menu.savefile.load_game_at  ; A9EF 20 F9 A9
    lda #$25    ; A9F2 A9 25
    jsr menu.stream_window_content  ; A9F4 20 6B A6
    sec             ; A9F7 38
    rts             ; A9F8 60
;==================================================================================================
	VERIFY_PC_TO_PATCH_END menu.savefile
    .endif  ;;_FEATURE_DEFERRED_RENDERING