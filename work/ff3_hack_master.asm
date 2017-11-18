; ff3_hack_master.asm
;
; description:
;	master file to assmeble
;
; version:
;	0.23
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
		.incbin	"base-binary/ff3_hack_base.nes.noheader"	;header must be stripped
	.endif	;BALANCED_VERSION
	.include "ff3.h.asm"
	.bank	$00
	.org	$8000
	.include "ff3_string.asm"
	.include "ff3_command_string.asm"
	.include "ff3_rand.asm"
	.include "ff3_fix.asm"

	.ifdef BETA
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
		;v0.7.9:
		.include "ff3_floor_treasure.asm"	;save
		;v0.7.3:
		.include "ff3_field_window.asm"	;consume(field_treasure_begin)
		;;
		.include "ff3_interrupt.asm"
		.ifdef EXPERIMENTAL
			.include "ff3_experimental.asm"
		.endif	;EXPERIMENTAL
	.endif	;BETA

	;.include "ff3_battle_calc.asm"
;==========================================================================================================