; encoding: utf-8
; ff3_charcode.h.asm:
;	defines charcter codes of ff3 (respecting the original implementation)
;==================================================================================================
;; codemap:
;; --  00 01 02 03 04 05 06 07    08 09 0a 0b 0c 0d 0e 0f
;; 00  \0 \n .. .. .. .. .. ..    .. .. .. .. .. .. .. ..
;; 10  .. .. .. .. .. .. .. ..    .. .. .. .. .. .. .. ..
;; 20  .. .. .. .. .. .. .. ..    .. が ぎ ぐ げ ご ざ じ
;; 30  ず ぜ ぞ だ ぢ づ で ど     ば び ぶ べ ぼ ぱ ぴ ぷ
;; 40  ぺ ぽ ヴ ガ ギ グ ゲ ゴ     ザ ジ ズ ゼ ゾ ダ ヂ ヅ
;; 50  デ ド バ ビ ブ ベ ボ パ     ピ プ ペ ポ  C  G  L  V
;; 60  盾 鎧 兜 腕 爪 本 杖 槌     槍 短 斧 剣 刀 琴 弓 鈴
;; 70  投 手  ◎  ×  ○  ●  E H     M P  X  を っ ゃ ゅ ょ
;; 80  _0 _1 _2 _3 _4 _5 _6 _7    _8 _9 あ い う え お か
;; 90  き く け こ さ し す せ     そ た ち つ て と な に
;; a0  ぬ ね の は ひ ふ へ ほ     ま み む め も や ゆ よ
;; b0  ら り る れ ろ わ ん ァ     ィ ゥ ェ ォ ッ ャ ュ ョ
;; c0  ゛ ゜ ー ･･ _! _? _% _/     _: 『 ア イ ウ エ オ カ
;; d0  キ ク ケ コ サ シ ス セ     ソ タ チ ツ テ ト ナ ニ
;; e0  ヌ ネ ノ ハ ヒ フ 「 ホ     マ ミ ム メ モ ヤ ユ ヨ
;; f0  ラ リ ル レ ロ ワ ン ┏     ━ ┓ ┃ ┃ ┗ ━ ┛ __
;; =======================================================
CHAR.NULL = $00
CHAR.EOL = $01
CHAR.TREASURE_NAME = $02
CHAR.TREASURE_GIL = $03
CHAR.INN_CHARGE = $04
CHAR.PARTY_GIL = $05
CHAR.NOT_IMPL_06 = $06
CHAR.ALLY_NPC_NAME = $07
CHAR.CAPACITY = $08
CHAR.PADDING_TO_EOL = $09
CHAR.PAGING = $0a
CHAR.NOT_IMPL_0B = $0b
CHAR.LEADER_NAME = $0c
CHAR.UNKNOWN_0D = $0d
CHAR.NOT_IMPL_0E = $0e
CHAR.DUSTBOX = $0f
;;
;;10-13: status of a player character. lower 2-bits represents an index of character.
CHAR.PLAYER1_PARAMS = $10   ;param = kind of parameter
CHAR.PLAYER2_PARAMS = $11   ;param = kind of parameter
CHAR.PLAYER3_PARAMS = $12   ;param = kind of parameter
CHAR.PLAYER4_PARAMS = $13   ;param = kind of parameter
;;14: left-align (tabulate) text by the parameter.
CHAR.SPACE_FILL = $14   ;param = fill length

;;15-17: left-align (tabulate) text by the parameter,
;;setup internal structure for later reference,
;;and increment the menu-item index. (stored at $78f1/79f1/7af1)
CHAR.SETUP_WINDOW1_MENUITEM = $15   ;; command dialog. (menu command, inn (yes/no), job, shop command)
CHAR.SETUP_WINDOW2_MENUITEM = $16   ;; target dialog. (magic, item) + shop offerings.
CHAR.SETUP_WINDOW3_MENUITEM = $17   ;; item dialog. (cast, use, equip, withdraw, sell)

CHAR.TEXT_REF = $18     ;param = text_id
CHAR.ITEM_NAME_IN_SHOP = $19   ;param = index into $7b80(shop items).
CHAR.ITEM_NAME_IN_MENU = $1a    ;param: item index
CHAR.ITEM_NAME_IN_STOMACH = $1b   ;;param: index in the stomach. (of fatty choccobo)
CHAR.ITEM_COUNT = $1c   ;param: item index
CHAR.ITEM_COUNT_IN_STOMACH = $1d   ;param: index in the stomach. (of fatty choccobo)
CHAR.JOB_NAME = $1e     ;param: job_id
CHAR.JOB_CHANGE_COST = $1f   ;param: job_id
CHAR.ITEM_NAME_IN_EQUIP_SELECTION = $20 ;param: item index
CHAR.ITEM_PRICE_IN_SHOP = $21   ;param: item index in the shop offerings list.
CHAR.ITEM_NAME_IN_TARGET = $22  ;param: item index. note: first byte of the name is skipped.

;;
CHAR.REPLACEMENT_BEGIN = $10    ;inclusive
CHAR.REPLACEMENT_END = $28      ;exclusive. ($28 = space)
;;
CHAR.SPACE = $28
;;
CHAR.NEED_COMPOSITION_END = $5c
CHAR.AVAILABLE_ONLY_IN_MENU_BEGIN = $70

;; ----------------------------------------------------------------------------
;; macros.
IS_PRINTABLE_CHAR   .macro 
    .is_printable_char_\@:
    ;;[in]
    ;;	u8 A: charcode, destructed on exit
    ;;[out]
    ;;	bool carry: 1 = printable (not a replacement char), 0 = replacement.
        sec
        sbc #CHAR.REPLACEMENT_BEGIN
        cmp #(CHAR.REPLACEMENT_END - CHAR.REPLACEMENT_BEGIN)
    ;;  rts
    .endm   ;IS_PRINTABLE_CHAR 
