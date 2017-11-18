; encoding: utf-8
; ff3_charcode.h.asm:
;	defines charcter codes of ff3 (respecting the original implementation)
;==================================================================================================
CHAR.NULL = $00
CHAR.EOL = $01
CHAR.REPLACEMENT_BEGIN = $10    ;inclusive
CHAR.REPLACEMENT_END = $28      ;exclusive. ($28 = space)
CHAR.SPACE = $28

;; =======================================================
;; --  00 01 02 03 04 05 06 07    08 09 0a 0b 0c 0d 0e 0f
;; 00  \0 \n \t .. .. .. .. ..    .. .. .. .. .. .. .. ..
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
