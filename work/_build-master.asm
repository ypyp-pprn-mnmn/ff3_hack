; _build-master.asm
;
; description:
;	master file to assmeble
;
; version:
;	0.24
;
;----------------------------------------------------------------------------------------------------------
	.inesprg	$20		;total 512k
	.inesmap	$04		;MMC3
	.inesmir	$03		;horizontal | sram
	.list
	.mlist
;----------------------------------------------------------------------------------------------------------
	.ifdef BALANCED_VERSION
		.ifdef EXTRA_MAP
			.incbin "extra-map/ff3_extra_map.nes.noheader"
		.else
			.incbin "base-binary/ff3_hack_base_ex.nes.noheader"
		.endif
	.else
		.incbin	"base-binary/ff3_plain.nes.noheader"	;header must be stripped
	.endif	;BALANCED_VERSION
	.include "ff3.h.asm"
	.bank	$00
	.org	$8000
	.include "ff3_fix.asm"
	.include "ff3_jobx_redmage.asm"		;; 0.8.0

	.ifdef BETA
		;;TODO: guard the below 3 with another feature flag(s)
		;;	string, commnad_string are actually dependecy of another files.
		.include "ff3_string.asm"
		.include "ff3_command_string.asm"
		.include "ff3_rand.asm"

		.include "ff3_enemy_target.asm"	;save
		.include "ff3_calc_player_param.asm"	;save
		.include "ff3_blow_effect.asm"	;save
		;
		.include "ff3_present_battle.asm"	;save
		.include "ff3_info_window.asm"		;save
		.include "ff3_executeAction.asm"	;save
		
		.include "ff3_command_window.asm"

		.include "ff3_commands.asm"	;saving a lot
		.include "ff3_command_ex.asm"; consume( infoWindow_free, calc_player_param_free )

		.include "ff3_item_window.asm"	;save
		.include "ff3_magic_window.asm"	;save
		.include "ff3_window.asm"		;consume( origin )

		.include "ff3_command_04.asm"	;consume( genCode_end, getCommandInput_end )
		.include "ff3_command_13.asm"	;save
			
		.include "ff3_b34_play_effect.asm"	;save
		.include "ff3_b30_invokeBattleFunction.asm"
		
		.include "ff3_cmdx_provoke.asm"		;consume( origin )
		.include "ff3_cmdx_disordered_shot.asm"	;consume( origin )
		.include "ff3_cmdx_abyss.asm"	;consume( origin , pb_free )
		.include "ff3_cmdx_raid.asm"	;consume( origin )
		;v0.6.1:
		.include "ff3_present_scene.asm"
		;v0.7.0:
		.include "ff3_doFight.asm"
		;v0.7.8:
		.include "ff3_calcDamage.asm"
		;;v0.8.0:
		.include "ff3_interrupt.asm"
		.include "ff3_poison.asm"
		.include "ff3_battle-specials.asm"
	.endif	;;BETA
	.ifdef _OPTIMIZE_FIELD_WINDOW
		;; TODO: the below is here only as the dependency of other files.
		;; it is better to pull up this as an individual feature
		;; as long as it can be.
		.include "ff3_floor_treasure.asm"
		;;v0.8.0:
		.include "ff3_field_window_driver.asm"
		.include "ff3_textd.asm"	;save
		.include "ff3_field_window_renderer.asm"
		.include "ff3_field_render_x.asm"	;consume
		
		.include "ff3_menu_of_stomach.asm"
		;;v0.8.x:
		.include "ff3_menu_savefile.asm"
	.endif	;;_OPTIMIZE_FIELD_WINDOW
	;;v0.9.0:
	.include "ff3_bank_switch.asm"

	.ifdef EXPERIMENTAL
		.include "ff3_experimental.asm"
	.endif	;;EXPERIMENTAL
	
	;.include "ff3_battle_calc.asm"
;==========================================================================================================