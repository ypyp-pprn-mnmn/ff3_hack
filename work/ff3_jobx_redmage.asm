;; encoding: utf-8
;; ff3_jobx_redmage.asm
;;
;; description:
;;	declares tweaked parameters of Red Mage.
;;
;; version:
;;	0.1.0
;;=================================================================================================
	.ifdef _BOOST_REDMAGE
;; ### 装備タイプ33h変更
	FILEORG $00999		;; 装備タイプ33h
	.db $20,$00,$a0		;; 14 00 08(賢導白) => 20 00 a0(忍ナ赤)

;; ### ブレイクブレイドとディフェンダーの装備タイプ変更
	FILEORG $61588+7	;; ディフェンダー
	.db $33				;; 0E(忍ナ) => 33
	FILEORG $615a8+7	;; ブレイクブレイド
	.db $33				;; 0E(忍ナ) => 33

;; ### Lv5魔法の行使可能職タイプ変更
;; itemid >= $c8
;; $30:98c0 MagicParam magicData[0x38]
;; 属性? 命中率? 威力 追加効果? kind? ?? effect? 装備タイプ
	FILEORG $61968+7	;; サンダガ
	.db $2f				;; 2e(賢魔黒) => 2f(賢魔赤黒)
	FILEORG $61970+7	;; キル
	.db $2f				;; 2e => 2f
	FILEORG $61978+7	;; イレース
	.db $2f				;; 2e => 2f
	FILEORG $61980+7	;; ケアルダ
	.db $31				;; 30(賢導白) => 31(賢導赤白)
	FILEORG $61988+7	;; レイズ
	.db $31				;; 30 => 31
	FILEORG $61990+7	;; プロテス
	.db $31				;; 30 => 31

;; ### MP成長変更
;;struct LvUpParam {
;;	u8 inc : 3;	//この値だけステータスが上がる
;;	u8 men : 1;	//onならステータス上昇
;;	u8 int : 1;
;;	u8 vit : 1;
;;	u8 agi : 1;
;;	u8 str : 1;
;;	u8 mp;//bit7 87654321 bit0
;;}
;;$39:a5aa LvUpParam redmage[98]
;; (original)
;; 	000725D0   01 04 F9 02 41 09 99 04 41 00 F9 0B 01 04 41 00
;; 	000725E0   99 0A 61 01 D9 04 01 08 D9 02 61 05 99 00 41 08
;; (tweaked)
;; 	000725D0   01 04 F9 12 41 19 99 04 41 10 F9 0B 01 14 41 00
;; 	000725E0   99 0A 61 11 D9 04 01 08 D9 02 61 05 99 00 41 08
	FILEORG $725aa+(20<<1)+1	;; Lv21 725d3
	.db $02|(1<<(5-1))
	FILEORG $725aa+(21<<1)+1	;; Lv22 725d5
	.db $09|(1<<(5-1))
	FILEORG $725aa+(23<<1)+1	;; Lv24 725d9
	.db $00|(1<<(5-1))
	FILEORG $725aa+(25<<1)+1	;; Lv26 725dd
	.db $04|(1<<(5-1))
	FILEORG $725aa+(28<<1)+1	;; Lv29 725e3
	.db $01|(1<<(5-1))
	.endif	;;_BOOST_REDMAGE
;--------------------------------------------------------------------------------------------------