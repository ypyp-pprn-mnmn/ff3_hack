; encoding: utf-8
; ff3.h.asm:
;	master include file for ff3 hacking
;==================================================================================================
;macros
	.include "macro.h.asm"
;consts
	.include "ff3_const.h"
	.include "ff3_charcode.h.asm"
;proc addrs
	.include "ff3_30-31.h"
	.include "ff3_32-33.h"
	.include "ff3_34-35.h"
;--------------------------------------------------------------------------------------------------
;$3e-3f
field.callSoundDriver			= $c750
field.update_window_attr_buff	= $c98f
field.set_bg_attr_for_window	= $c9a9
field.merge_bg_attr_with_buffer = $cab1
field.update_vram_by_07d0	= $cb6b	;[in] $07d0[16]: vram address low, $07e0[16]: vram high, $07f0[16]: vram value
field.get_input				= $d281	;$3e:d281 field::get_input
;;
field.sync_ppu_scroll_with_player	= $e571
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

textd.draw_in_box = $eefa
textd.eval_replacement = $f02a
textd.switch_to_text_bank_and_continue_drawing = $f291
textd.deref_text_id = $f2d8

textd.tile_map_lower = $F4E1	;static table that maps charcode into tile id
textd.tile_map_upper = $f515	;static table that maps charcode into tile id

;floor.get_item_price = $f5d4	;ff3_floor_treasure.asm

;field.calc_draw_width_and_init_window_tile_buffer = $f670
;field.init_window_tile_buffer = $f683 ;fill 0780..79d/07c0..7dd with 0xFF
;field.upload_window_content	= $f6aa	;impl replaced but stay at the original addr
;;
;switchBanksTo3c3d			= $f727
switch_to_character_logics_bank = $f727
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
loadTo7400Ex				= $fda6
copyTo7400					= $fddc
;call_30_9e58				= $fdf3
invoke_b30_battleFunction	= $fdf3
waitNmiBySetHandler			= $ff00
call_switch_2banks			= $ff03	; => jmp $ff17
call_switch1stBank			= $ff06	; => jmp $ff0c
call_switch2ndBank			= $ff09	; => jmp $ff1f
;----------------------------------------------------------------------------------------------------------
;well known vars
pNmiHandler			= $0101	;$0100 jmp xxxx, sometimes just rti :$0100 rti (0x40)
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
presentActionParams	= $78d5	;?,actor,action,targetflag,effectmsg,messages
battleProcessType	= $78d5
actionName			= $78d7
targetName			= $78d8
effectMessage		= $78d9
battleMessages		= $78da
battleMessageCount	= $78ee
;pTileArray			= $7ac0
selectedMagicLv		= $7ac7	;[4]
stringCache			= $7ad7
battleRandoms		= $7be3
encounterId			= $7ced
isRendering			= $7cf3

groupToEnemyIdMap	= $7d6b	;*4
;;indexToGroupMap		= $7da7
enemyPos			= $7dd7	;{x,y}*8
;param for playing (magic) effect
play_weaponRight		= $7e1f
play_weaponLeft			= $7e20
play_damages			= $7e4f
play_damageTarget		= $7e6f	;0=player
play_actorBits			= $7e98
play_arrowTarget		= $7e96
play_castTargetBits		= $7e99	;battle
play_effectTargetSide	= $7e9a	;80:actor enemy 40:target enemy
play_effectTargetBits	= $7e9b	;param of presentActionEffect($33:b68d)
play_magicType			= $7e9d
play_reflectedTargetBits= $7eb8 ;param of presentEffectAtTarget($33:b64f)

effectHandlerIndex	= $7ec2	;
effectHandlerFlag	= $7ec3
effect_enemyStatus	= $7ec4
indexToGroupMap		= $7ecd	;*8
battleMode			= $7ed8	; 80:boss? 20:fireCannon(invincible) 10:disallowEnlarge 08:? 01:disallowEscape
play_protectionTargetBits = $7edf
effect.protection_causal_bits = $7ee0
play_segmentedGroup = $7ee1

soundDriver_playingMusicId = $7f40
soundDriver_lastMusicId = $7f41
soundDriver_control	= $7f42	;01:playNew(7f43) 02:playLast(7f41,saved when 01) 04:stop 80:playOn
soundDriver_musicId	= $7f43
soundDriver_effectId= $7f49	;msb should be 1
;----------------------------------------------------------------------------------------------------------
;in memory structs
backpackItems		= $60c0
playerBaseParams	= $6100
playerEquips		= $6200
playerBattleParams	= $7575	;$40*4
enemyBattleParams	= $7675	;$40*8
;----------------------------------------------------------------------------------------------------------
;in rom structs
userFlags			= $00900
stringPtrTable		= $30000
monsterBaseParams	= $60000	;8*256
monsterBattleParams = $61000
itemBaseParams		= $61400
initialMps			= $73b88
lvupParamPtrTable	= $7ad59
;handler tables
commandIdToEffectMap	= $683f8
commandEffectHandlers	= $6843e
commandWindowHandlers	= $69a16
commandHandlers			= $69fac
;------------------------------------------------------------------------------------------------------
TEMP_RAM = $7900	;we cannot use stack regein due to dugeon's floor save
;------------------------------------------------------------------------------------------------------
