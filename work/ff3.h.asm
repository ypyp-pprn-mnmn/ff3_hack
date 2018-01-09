; encoding: utf-8
; ff3.h.asm:
;	master include file for ff3 hacking
;==================================================================================================
;macros
	.include "macro.h.asm"
;consts
	.include "ff3_const.h.asm"
	.include "ff3_charcode.h.asm"
	.include "ff3_party_and_player.h.asm"
	.include "ff3_field_window.h.asm"
;proc addrs
	.include "ff3_30-31.h.asm"
	.include "ff3_32-33.h.asm"
	.include "ff3_34-35.h.asm"
;--------------------------------------------------------------------------------------------------
;;$36
sound.udpate_keyoff_timers = $831d
;;$3c-3d
;;TODO: move this into separate file.
menu.init_input_states = $9592
menu.stream_window_content = $a66b
menu.savefile.load_game_at = $a9f9
menu.get_window_metrics = $aabc
;menu.get_eligibility_for_item_for_all = $aee3

;$3e-3f
field.call_sound_driver			= $c750
field.update_window_attr_buff	= $c98f
field.set_bg_attr_for_window	= $c9a9
field.merge_bg_attr_with_buffer = $cab1
field.update_vram_by_07d0	= $cb6b	;[in] $07d0[16]: vram address low, $07e0[16]: vram high, $07f0[16]: vram value
field.get_eligibility_flags = $d113
field.get_input				= $d281	;$3e:d281 field::get_input
;;
floor.main_loop = $e1dc
field.sync_ppu_scroll_with_player	= $e571
floor.load_data = $e7ec
field.switch_to_floor_logics_bank = $eb28
;field.seek_text_to_next_line = $eba9
;field.hide_sprites_under_window = $ec18
;field.await_and_get_next_input	= $ecab
;field.advance_frame_with_sound	= $ecd8	;[in] $93 : bank, [in,out] $f0: frame_counter
;field.restore_bank			= $ecf5	;[in] $57: bank
;field.draw_inplace_window	= $ecfa	;fall through to field.draw_window_box
;field.init_window_attr_buffer	= $ed56	
;field.get_window_metrics	= $ed61	;[in] u8 $96: window_id / [out] $38, $39, $3c, $3d
;field.sync_ppu_scroll		= $ede1
;field.stream_string_in_window	= $ee65
;field.load_and_draw_string	= $ee9a
;field.draw_string_in_window	= $eec0

;textd.draw_in_box = $eefa
;textd.eval_replacement = $f02a
;textd.deref_param_text = $f09d
;textd.deref_param_text_unsafe = $f0a1
;textd.draw_embedded_text = $f0c5
;textd.continue_with_text = $f291
;textd.deref_text_id = $f2d8
;textd.draw_player_name = $f316
;field.get_max_available_job_id = $f38a
;textd.setup_output_ptr_to_next_column = $f3ac
;textd.save_text_ptr = $f3e4
;textd.restore_text_ptr = $f3ed
field.vram_addr_map.high = $f4a1	;;static table that maps Y coords into addr
field.vram_addr_map.low = $f4c1		;;static table that maps Y coords into addr
textd.tile_map_lower = $F4E1	;static table that maps charcode into tile id
textd.tile_map_upper = $f515	;static table that maps charcode into tile id

;floor.get_item_price = $f5d4	;ff3_floor_treasure.asm

;field.calc_draw_width_and_init_window_tile_buffer = $f670
;field.init_window_tile_buffer = $f683 ;fill 0780..79d/07c0..7dd with 0xFF
;field.upload_window_content	= $f6aa	;impl replaced but stay at the original addr
;;
;switchBanksTo3c3d			= $f727
switch_to_character_logics_bank = $f727
thunk.call_get_eligibility_for_item = $f806
;; ppu drivers, mostly used only in battle mode
ppud.do_sprite_dma			= $f8aa
ppud.update_sprites_and_palette_after_nmi = $f8b0
ppud.update_sprites_after_nmi = $f8c5;
ppud.sync_registers_with_cache = $f8cb;
;;
setVramAddr					= $f8e0	;[in] a:high, x:low
mul_8x8_reg					= $f8ea	;a,x = a * x
call_2e_9d53				= $fa0e
doBattle					= $fa26
;waitNmi						= $fb80	;wait on $05 clear
ppud.await_nmi_completion		= $fb80
switchFirst2Banks			= $fb87	;[in] a : per16k bank index
getPad1Input				= $fbaa	;[out] $12 : inputFlags
getBattleRandom				= $fbef	;[out] a : rand [min:x - max:a] max included
initBattleRandom			= $fc27
div_16						= $fc92	;$1c = $18,19 / $1a,1b; $1d = $18,19 % $1a,1b
mul_8x8						= $fcd6	;$1a,1b = a * x
mul_16x16					= $fcf5	;$1c,1d,1e,1f = $18,19 * $1a,1b
flagTargetBit				= $fd20
clearTargetBit				= $fd2c
maskTargetBit				= $fd38
shiftLeft6					= $fd3c
shiftRight6					= $fd43
loadStringWorker			= $fd4a
get2byteAtBank18			= $fd60
battle.eligibility_flags_from_user_type = $fd8b
loadTo7400Ex				= $fda6
copyTo7400					= $fddc
;call_30_9e58				= $fdf3
invoke_b30_battleFunction	= $fdf3
waitNmiBySetHandler			= $ff00
call_switch_2banks			= $ff03	; => jmp $ff17
thunk.switch_2banks			= $ff03
call_switch1stBank			= $ff06	; => jmp $ff0c
call_switch2ndBank			= $ff09	; => jmp $ff1f
;--------------------------------------------------------------------------------------------------
;well known vars
pNmiHandler			= $0101	;$0100 jmp xxxx, sometimes just rti :$0100 rti (0x40)
nmi_handler_entry	= $0100
pIrqHandler			= $0104	;$0103 jmp xxxx, sometimes just rti :$0103 rti
irqFlag				= $00
enableScanlineCounter = $01	;mmc3's irq
irqCountDown		= $03
nmiFlag				= $05
ppuCtrl1SetOnNmi	= $06
ppuCtrl1SetOnIrq	= $08
ppuCtrl2SetOnNmi	= $09
scrollXSetOnNmi		= $0c
scrollYSetOnNmi		= $0d
scrollXSetOnIrq		= $10
scrollYSetOnIrq		= $11
inputBits			= $12	;used in battle phase. see also getPad1Input($3f:fbaa)
;bit7< A B select start up down left right >bit0
field.pad1_bits		= $20	;order of bits averse to those in battle ($12). see also field::get_input($3e:d281).
;; ---
floor.map_x = $29
floor.map_y = $2a
;; ---
selectTarget_behavior		= $b3	;param of presentSceneFunction10($2e:9d53)
selectTarget_selectedBits	= $b4
selectTarget_targetFlag		= $b5
playerX				= $c0	;*4
playerY				= $c4	;*4
playSoundEffect		= $c9	;1=play
soundEffectId		= $ca	; played on irq if $c9 != 0
targetStatusCache	= $e0	;in process battle phase
actorStatusCache	= $f0	;
field.frame_counter	= $f0	;
field.ppu_ctrl_cache= $ff	;
field.sprite_attr_cache		= $0200	;first $40bytes contains player and cursor sprites
field.bg_attr_table_cache	= $0300	;128bytes. exactly the same format as what stored in PPU

;; ------------------------------------------------------------------------------------------------
;; battle-mode.
battle.reflected = $7574
;presentActionParams	= $78d5	;?,actor,action,targetflag,effectmsg,messages
battle.p_reflector = $78b5	;;BattleCharacter*
battle.continuity_flags = $78d3	;;80: no playrs can continue fight, 40: all enemies gone, 02: successfully escaped.
battleProcessType	= $78d5	;;deprecated
battle.command_chain_id = $78d5
actionName			= $78d7	;;deprecated
battle.action_name	= $78d7
targetName			= $78d8	;;deprecated
battle.target_name	= $78d8
effectMessage		= $78d9
battle.effect_name	= $78d9
battleMessages		= $78da	;;deprecated
battle.messages		= $78da
battleMessageCount	= $78ee

;pTileArray			= $7ac0
selectedMagicLv		= $7ac7	;[4]
stringCache			= $7ad7
battleRandoms		= $7be3
battle.defence_flags = $7ce4	;;[4], 
encounterId			= $7ced
isRendering			= $7cf3

groupToEnemyIdMap	= $7d6b	;*4
;;indexToGroupMap		= $7da7
enemyPos			= $7dd7	;{x,y}*8
;param for playing (magic) effect
play_weaponRight		= $7e1f
play_weaponLeft			= $7e20
play_damages			= $7e4f
effect.damages_to_show_1st = $7e4f
effect.damages_to_show_2nd = $7e5f
play_damageTarget		= $7e6f	;0=player
play_arrowTarget		= $7e96
play_actorBits			= $7e98
effect.actor_flags = $7e98
play_castTargetBits		= $7e99	;battle
effect.target_flags = $7e99
play_effectTargetSide	= $7e9a	;80:actor enemy 40:target enemy
effect.side_flags = $7e9a
play_effectTargetBits	= $7e9b	;param of presentActionEffect($33:b68d)
play_magicType			= $7e9d
play_reflectedTargetBits= $7eb8 ;param of presentEffectAtTarget($33:b64f)
effect.reflected_target_flags = $7eb8

effect.target_index = $7ec1
effectHandlerIndex	= $7ec2	;
effect.scene_id = $7ec2
effectHandlerFlag	= $7ec3
effect_enemyStatus	= $7ec4
effect.enemy_status = $7ec4
indexToGroupMap		= $7ecd	;*8
battleMode			= $7ed8	; 80:boss? 20:fireCannon(invincible) 10:disallowEnlarge 08:? 01:disallowEscape
play_protectionTargetBits = $7edf
effect.protection_causal_bits = $7ee0
play_segmentedGroup = $7ee1
effect.proliferated_group = $7ee1
;--------------------------------------------------------------------------------------------------
;; sound driver
sound.music_id = $7f40
sound.previous_music_id = $7f41
sound.request = $7f42	;01:play next(7f43) 02:play previous(7f41,saved when 01) 04:stop 80:play on
sound.next_music_id = $7f43;
sound.master_volume = $7f44	;;details TBC. valid only lower 4 bits.
sound.bpm = $7f45	;;BPM.
sound.beat_counter.low = $7f46		;; decremented by 150 (= 240 * 5 / 8) per a callout to the sound driver.
sound.beat_counter.high = $7f47		;; on the other hand, length of a whole note is defined to 96 (60 * 8 / 5).
sound.effect_id = $7f49	;msb should be 1
;; track control flags. (details TBC)
sound.track_controls = $7f4a
;; stream pointers.
sound.p_streams.low = $7f51
sound.p_streams.high = $7f58
sound.note_lengths = $7f5f	;; in 96th of a whole note.
sound.note_octaves = $7f66	;; [0,6). details TBC.
sound.note_pitch_timers.low = $7f6d		;;'timer' value of the equation: wave frequency = CPU frequency / (16 * (timer + 1))
sound.note_pitch_timers.high = $7f74	;;note: APU outputs 8-phased 1-bit waveform. APU frequency = CPU frequency / 2.
sound.volume_controls = $7f7b	;; will be fed into $4000+4n. details TBC. 
sound.sweep_controls = $7f82	;; will be fed into $4001+4n. details TBC. 
sound.duty_controls = $7f89		;; will be fed into $4000+4n. details TBC. 
sound.volume_envelopes.control = $7f90	;; details tbc.
sound.key_off_timers.low = $7f97	;; in 96th of a whole note. (but defined as 2/3 of corresponding notes)
sound.key_off_timers.high = $7f9e	;;

sound.loops.control = $7fa5		;; 00 = use $7fac; !00 = use $7fb3. note: this variable is initilized on stream load, and set to 0xff.
sound.loops.counter_1 = $7fac
sound.loops.counter_2 = $7fb3

sound.volume_envelopes.type = $7fba	;; tbc. used to index curve patterns
;;sound.volume_envelopes.x = $7fc1		;;tbc.
sound.volume_envelopes.phase = $7fc8	;; tbc. used to index stream (pointed to by $9a7c, which is looked up by $7fc1) of volumes.
sound.volume_envelopes.volume = $7fcf	;; tbc.
sound.volume_envelopes.interval = $7fd6	;; tbc. 2/3 of bpm. (as timer delta is 2/3 of what for play notes)
sound.volume_envelopes.timer = $7fdd	;; triggers lowering volume,  once reached to 100 (0x64)
sound.volume_envelopes.countdown = $7fe4	;; triggers volume change

sound.pitch_modulations.type = $7feb	;; tbc.
sound.pitch_modulations.phase = $7ff2	;; tbc.
sound.pitch_modulations.timer = $7ff9	;; tbc.
;--------------------------------------------------------------------------------------------------
;world-mode
world.map_chip_buffer = $7000; 256 tiles x 15 lines
;--------------------------------------------------------------------------------------------------
;floor-mode
floor.npc_params_1 = $7000; 0x10 bytes x 11 npcs
floor.npc_params_2 = $7100; 0x10 bytes x 11 npcs
floor.map_chip_buffer = $7400	;0x400 = 32x32 bytes. @see $3e:cbfa. reloaded after backed from menu.
floor.event_script_buffer = $7b00	;0x40 bytes. @see $3e:ea04.
floor.label_text_buffer = $7b01	;max 0x100 bytes. @see $3e:d1b1.
floor.tile_pattern_data = $7f00	;tbc. @see $3e:de5a.
;--------------------------------------------------------------------------------------------------
;menu-mode
menu.job.costs = $7200	;;tbc. $3d:ad85
;; copied from $6000. 0x400 bytes. details tbc. copies happen at $3d:aa2b
;; copied back to $6000 at $3d:aa08. both are called when the save menu is to be loaded
menu.save.game_state_copy = $7400
;;@see $3f:fb17 saveFieldVars for below two.
menu.saved_field_variables_E0_FF = $7550	;0x20 bytes. $7470+E0+x.
menu.saved_field_variables_00_CF = $7480	;0xd0 bytes
;; working sets for dialogs
menu.choose_dialog_1 = $7800	;; command dialog. (menu command, inn (yes/no), job, shop command, save)
menu.choose_dialog_2 = $7900	;; target dialog. (of magic, of item) , shop offerings, load
menu.choose_dialog_3 = $7a00	;; item dialog. (cast, use, equip, withdraw, sell)
menu.shop_offerings = $7b80	;[8], item_id
menu.shop_item_price.low = $7b90;	[8] lower 8-bits of price(24bits)
menu.shop_item_price.mid = $7b98; [8] middle 8-bites of price(24bits)
menu.shop_item_price.high = $7ba0; [8] middle 8-bites of price(24bits)
menu.shop_item_ask.low = $7ba8	; [8] @see $3d:b220
menu.shop_item_ask.mid = $7bb0
menu.shop_item_ask.high = $7bb8
menu.available_items_in_stomach = $7c00; item_id[256]
menu.job.params = $7c00	;details tbc. $3d:adf2 get_job_parameter
;--------------------------------------------------------------------------------------------------
;in memory structs

;; ---
playerBattleParams	= $7575	;$40*4
enemyBattleParams	= $7675	;$40*8
;--------------------------------------------------------------------------------------------------
;string pointers
textd.message_texts = $8000;
textd.menu_window_contents = $8200
textd.status_and_area_names = $8200	;$18:8200 = $30200. see also $3e:d1b1
textd.item_names = $8800;
;--------------------------------------------------------------------------------------------------
;in rom structs
userFlags			= $00900
rom.eligibility_flags = $00900
stringPtrTable		= $30000
monsterBaseParams	= $60000	;8*256
monsterBattleParams = $61000
itemBaseParams		= $61400
rom.item_params		= $61400
initialMps			= $73b88
lvupParamPtrTable	= $7ad59
;handler tables
commandIdToEffectMap	= $683f8
commandEffectHandlers	= $6843e
commandWindowHandlers	= $69a16
commandHandlers			= $69fac
;--------------------------------------------------------------------------------------------------
TEMP_RAM = $7900	;we cannot use stack region due to dugeon's floor save
;--------------------------------------------------------------------------------------------------
