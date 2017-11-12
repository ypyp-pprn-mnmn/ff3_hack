; ff3_present_scene.asm
;
;description:
;	replaces presentScene()
;
;version:
;	0.01 (2006-10-28)
;
;======================================================================================================
ff3_present_scene_begin:

;	[in] u8 A : commandId (00-25h)
;		01 : さがる(char:$52)
;		02 : 指示するキャラが前に出る(char:$52)
;		03 : playEffect_05 (back(03) )
;		04 : playEffect_04 (forward(02) )
;		07 : playEffect_0e(死亡・味方)
;		08 : $b38e 行動中のキャラを示す(一定のラインまで前に出る)
;		09 : $b38b 行動終了したキャラを元の位置まで戻す
;		0a : playEffect_0e(死亡・敵 $7e=死亡bit(各bitが敵1体に相当) )
;		0b : playEffect_0e
;			(蘇生? bitが立っている敵の枠に敵がいたならグラ復活
;			 生存かつ非表示の敵がいたとき $7e=生存bit で呼ばれる)
;		0C : 敵生成(召還・分裂・増殖) playEffect_0F (disp_0C)
;		0d : playEffect_0c (escape(06/07) : $7e9a(sideflag) < 0)
;		0e :
;		
;		0F : prize($35:bb49)
;		10 : 対象選択
;		12 : 打撃モーション&エフェクト(char:$52)
;		13 : presentCharacter($34:8185)
;		14 : playEffect_00 (fight/sing 被弾モーション?)
;		15 : playEffect_06 (defend(05) )
;		16 : playEffect_09 (charge(0f) 通常)
;		17 : playEffect_09 (charge(0f) ためすぎ)
;		18 : playEffect_07 (jump(08) )
;		19 : playEffect_08 (landing(09) )
;		1a : playEffect_0a (intimidate(11) )
;		1b : playEffect_0b (cheer(12) )
;		1c : playEffect_0F (disp_0C) ダメージ表示?
;		1d : playEffect_01 (command13/ cast/item)
;		1f : playEffect_00 行動する敵が点滅
;		20 : playEffect_00 (fight/sing 敵の打撃エフェクト?)
;		21 : playEffect_0d (escape(06/07) : $7e9a(effectside) >= 0)
;		22 : playEffect_01 (magicparam+06 == #07)
;		23 : playEffect_01 (magicparam+06 == #0d)
;		24 : playEffect_0c (command15)
;	[in] u8 X : actorIndex
;	[out] u8 $7d7d : 0
	INIT_PATCH $2f,$af4e,$afc0

presentScene:
;.handlers = $af74
	stx <$95
	asl a
	clc
	adc #LOW(.handlers)
	sta <$93
	lda #HIGH(.handlers)
	sta <$94
	lda #$6c
	sta <$92
	tya
	pha
	txa
	pha
	jsr $0092
	pla
	tax
	pla
	tay
	rts
;$2f:af74 $af4e_funcTable;
.handlers:
	.dw $b469, $b3c7, $b3cd, $b42a
	.dw $b443, $b3f6, $b3d9, $b3d3
	.dw $b38b, $b38e, $b33e, $b343
	.dw $b348, $b34d, $b304, $b2eb

	.dw $b2fa, $b260, $b24f, $b24c
	.dw $b201, $b246, $b1d8, $b1e0
	.dw $b1cf, $b1c1, $b1b5, $b1af
	.dw $b1ac, $b15e, $b050, $b024

	.dw $b005, $af24, $afff, $afe7
	.dw $af44, $afd8
	;extra
	;$26
	.dw psx_blowOnly
	.dw psx_abyss
;------------------------------------------------------------------------------------------------------
;$2f:b352 moveCharacterBack
	INIT_PATCH $2f,$b352,$b388

moveCharacterBack:
;	[in] x : actorIndex
.goals = $7d7f
	jsr getMoveOffset
	clc
;fall through
moveCharacter_addAndStoreGoal:
.goals = $7d7f
	bmi .confused
		inc $7d7d
.confused:
	adc .goals,x
	sta .goals,x
	jmp $b45c	;

getMoveOffset:
;[out] u8 a,$7e : offset
	lda #0
	sta $7d7d
	txa
	asl a
	tay
	lda $7d9b,y
	and #$08
	beq .not_confused
;backattack
		lda #$f0
		bne .store_and_set_x
.not_confused:
		lda $7d8f,x
		lsr a
		lda #$10
		bcc .at_front_line
			asl a
	.at_front_line:
.store_and_set_x:
	sta <$7e
	rts
;------------------------------------------------------------------------------------------------------
;$2f:b38e moveCharacterForward
	INIT_PATCH $2f,$b38e,$b3c7

moveCharacterForward:
;	[in] x : actorIndex
.goals = $7d7f
	jsr getMoveOffset
	eor #$ff
	sec
	jmp moveCharacter_addAndStoreGoal
;------------------------------------------------------------------------------------------------------

psx_blowOnly:
	jsr $a9cf	;$a9cf();	
	jsr $a8ea	;loadBlowEffectParams();	// $a8ea();
	jmp $aef0	;dispatchEffectFunction_04();	//$aef0();	//打撃モーション
	
psx_abyss:
	jsr moveCharacterForward
	;presentScene_16 (charge)
	lda #0
	sta $7e19	;charge motion flag
	jsr $a9cf;
	jsr $a9b1;
	jsr $aefc;	dispatchEffectFunction_07();
	;jsr psx_blowOnly	;destorys x
	jsr $a9cf
	jsr $af14	;dispatchEffectFunction_0d
	lda #6
	jsr $a1b3	;clear sprites
	ldx <$95	;index
	jmp $b3c7	;backAndUpdatePpu
;$b3c7:
;======================================================================================================
	RESTORE_PC ff3_present_scene_begin