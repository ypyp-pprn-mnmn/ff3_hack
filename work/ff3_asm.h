; ff3_asm.h
;
; include file for hackcodes
;======================================================================================================
;consts
	.include "ff3_const.h"
;proc addrs
	.include "ff3_30-31.h"
	.include "ff3_32-33.h"
	.include "ff3_34-35.h"
;$3e-3f
field_callSoundDriver		= $c750
field_updateTileAttrCache	= $c98f	;field_update_window_attr_buff = $c98f
field_setTileAttrForWindow	= $c9a9
field_merge_bg_attributes_with_buffer = $cab1
field_update_vram_by_07d0	= $cb6b	;[in] $07d0[16]: vram address low, $07e0[16]: vram high, $07f0[16]: vram value
field_hide_sprites_around_window = $ec18
field_restore_bank			= $ecf5	;[in] $57: bank
;field_fill_07c0_ff			= $ed56
;field_loadWindowTileAttr	= $ed56
field_init_window_attr_buffer	= $ed56
field_getWindowMetrics		= $ed61	;[in] u8 $96: window_id / [out] $38, $39, $3c, $3d
field_setBgScrollTo0		= $ede1
;field_putWindowTiles		= $f6aa
field_drawWindowContent		= $f6aa
switchBanksTo3c3d			= $f727
do_sprite_dma_from_0200		= $f8aa
updateDmaPpuScrollSyncNmiEx = $f8b0
updateDmaPpuScrollSyncNmi	= $f8c5	;(y is unchanged)
updatePpuScrollNoWait		= $f8cb
setVramAddr					= $f8e0	;[in] a:high, x:low
mul_8x8_reg					= $f8ea	;a,x = a * x
call_2e_9d53				= $fa0e
doBattle					= $fa26
waitNmi						= $fb80	;wait on $05 clear
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
inputBits			= $12
selectTarget_behavior		= $b3	;param of presentSceneFunction10($2e:9d53)
selectTarget_selectedBits	= $b4
selectTarget_targetFlag		= $b5
playerX				= $c0	;*4
playerY				= $c4	;*4
playSoundEffect		= $c9	;1=play
soundEffectId		= $ca	; played on irq if $c9 != 0
targetStatusCache	= $e0	;in process battle phase
actorStatusCache	= $f0	;
field_frame_counter	= $f0	;
field_sprite_attr_cache		= $0200
field_bg_attr_table_cache	= $0300	;128bytes. exactly the same format as what stored in PPU
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
TEMP_RAM = $7900	;we cannot use stack regeon due to dugeon's floor save
;------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------
;macros
INIT16	.macro	;addr,val
	lda #LOW(\2)
	sta \1
	lda #HIGH(\2)
	sta \1+1
		.endm

INIT16_x	.macro	;addr,val
	ldx #LOW(\2)
	stx \1
	ldx #HIGH(\2)
	stx \1+1
		.endm
			
ADD16	.macro	;addr,val		
	lda \1
	clc
	adc #LOW(\2)
	sta \1
	lda \1+1
	adc #HIGH(\2)
	sta \1+1
		.endm

ADD16by8	.macro
	lda \1
	clc
	adc \2
	sta \1
	bcc .add16by8_\@
		inc \1+1
	.add16by8_\@:
	.endm

SUB16	.macro	;addr,val		
	lda \1
	sec
	sbc #LOW(\2)
	sta \1
	lda \1+1
	sbc #HIGH(\2)
	sta \1+1
		.endm

SUB16by8	.macro	;addr,val
	lda \1
	sec
	sbc \2
	sta \1
	bcs .sub16by8_\@
		dec \1+1
	.sub16by8_\@:
	.endm

FILEORG	.macro
	.bank	(\1) >> 13
	.org	($8000 | ((\1) & $7fff))
		.endm
		
RESTORE_PC	.macro
	.bank	BANK(\1)
	.org	\1
		.endm
		
INIT_PATCH	.macro
	.bank	\1
	.org	\2
	.ds		((\3) - (\2))
	.org	\2
		.endm

	.ifdef RESPECT_ORIGINAL_ADDR
ORIGINAL_ADDR	.macro
	.org	\1
	.endm
	.else
ORIGINAL_ADDR	.macro
		.endm
	.endif
	
ALIGN_EVEN	.macro	;value to align
	.check_align_\@:
	.if (.check_align_\@ & 1) != 0
		nop	;pad
	.endif
	.endm	;ALIGN_EVEN

VERIFY_PC	.macro
	.verify_pc_\@:
	.if (.verify_pc_\@ > \1)
		.fail
	.endif
	.endm	;VERIFY_PC