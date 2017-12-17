
# $31:be43 battle.specials.try_to_apply_enchanted_status
> 実行したアクションの追加ステータスの適用を試みる。

### args:

#### in:
+	ActionParams $7400: parameters of executed action.
+	u8 $30: hit count
+	u8 $38: attack count
+	u8 $7c: hit count (with attr boost bonus)

#### in,out:
+	BattleCharacter* $6e: ptr to actor
+	BattleCharacter* $70: ptr to target.

### callers:
+	$31:b17c battle.specials.handle_00

### local variables:
+	u16 $18: hit count
+	u16 $1a: =100 (%)
+	u32 $1c: hit count * 100
+	u8 $24: # of attemps to apply status = hit count with attr bonus
+	u8 $25: % chance to successfully apply status = (hit count / swing count); "actual hit rate"

### notes:
write notes here

### (pseudo)code:
```js
{
/*
;; check if hit count > 0
    lda $7C         ; BE43 A5 7C
    beq LBE8F       ; BE45 F0 48
;; check if action executing is having some enchanted status
	lda $7403       ; BE47 AD 03 74
	beq LBE8F       ; BE4A F0 43
;; check if target is having resistance to that enchanted status
	ldy #$24        ; BE4C A0 24
	lda ($70),y     ; BE4E B1 70
	and $7403       ; BE50 2D 03 74
	bne LBE8F       ; BE53 D0 3A
	;; here all checks have passed
		lda $007C       ; BE55 AD 7C 00
		sta $18         ; BE58 85 18
		lda #$64        ; BE5A A9 64
		sta $1A         ; BE5C 85 1A
		lda #$00        ; BE5E A9 00
		sta $19         ; BE60 85 19
		sta $1B         ; BE62 85 1B
		;; $18 = hit count (with bonus)
		;; $1a = 100
		jsr mul16x16    ; BE64 20 F5 FC
		;; u32 $1c = $18 * $1a
		lda $38         ; BE67 A5 38
		sta $1A         ; BE69 85 1A
		lda $1C         ; BE6B A5 1C
		sta $18         ; BE6D 85 18
		lda $1D         ; BE6F A5 1D
		sta $19         ; BE71 85 19
		lda #$00        ; BE73 A9 00
		sta $1B         ; BE75 85 1B
		;; $18 = hit count * 100
		;; $1a = attack count
		jsr div         ; BE77 20 92 FC
		;; $1c = $18 / $1a ($1e = $18 mod $1a)
		lda $1C         ; BE7A A5 1C
		sta $25         ; BE7C 85 25
		lda $7C         ; BE7E A5 7C
		sta $24         ; BE80 85 24
		;; # of attemps: $24 = hit count with attr bonus
		;; success rate: $25 = (hit count / swing count); "actual hit rate"
		jsr getNumberOfRandomSuccess        ; BE82 20 28 BB
		beq LBE8F       ; BE85 F0 08
			lda $7403       ; BE87 AD 03 74
			sta $24         ; BE8A 85 24
			jmp applyStatus ; BE8C 4C F3 BB
; ----------------------------------------------------------------------------
LBE8F:
	rts             ; BE8F 60
*/
}
```

