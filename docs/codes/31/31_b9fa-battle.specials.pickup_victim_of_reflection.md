

# $31:b9fa battle.specials.pickup_victim_of_reflection
> リフレクの(適切な)反射対象をランダムに選択し、対象者として設定する

### args:

#### in:
+	u8 $7E88: action id (if magic, then it is item_id of which - 0xC8)
+	u8 $7EC1: target index

#### in,out:
+	BattleCharacter* $70: ptr to target.
	- on entry, this points to the target of the action executing.
	- on exit, this points to the victim of reflection.

+	u8 $7EB8: reflected_target_flags

#### out:
+	BattleCharacter* $78B5: the original target of the action executed (= $70 given to the call)
+	u8 $7574: reflection happen? on exit, set to 1 if so.

### callers:
+	$31:b17c battle.specials.handle_00

### local variables:
+	u8 $18: <= $7e88
+	u16 $1a: multiplication result, added into target offset.
+	u8 $21: random generator series index (= 1)
+	u8 $24: minimum index of victim, inclusive. 0x4 if victim is from enemy side, otherwise 0x0.
+	u8 $25: maximum index of victim, inclusive. 0xb if victim is from player side, otherwise 0x3.
+	u8 $26: index of (randomly) selected victim of reflection. [0-7] if victim is from enemy side, [0-3] otherwise.
+	u8 $27: index adjustment, 0xFC if victim is enemy side, otherwise 0x0.

### static references:
+	u8 $BB0E[?]

### notes:
this function does nothing if both actor and target is from the same side.

|actor/target | player | enemy
|-------------|--------|----------
|player       | skip   | ok
|enemy        | ok     | skip

### (pseudo)code:
```js
{
/*
; ----------------------------------------------------------------------------
    jsr getActor2C  ; B9FA 20 B5 A2
    bmi LBA04       ; B9FD 30 05
    	lda ($70),y     ; B9FF B1 70
    	bmi LBA08       ; BA01 30 05
LBA03:  
    	rts             ; BA03 60
; ----------------------------------------------------------------------------
LBA04: 
    lda ($70),y     ; BA04 B1 70
    bmi LBA03       ; BA06 30 FB
LBA08:
	lda $7E88       ; BA08 AD 88 7E
    sta $18         ; BA0B 85 18
    jsr shiftright6+3     ; BA0D 20 46 FD
    tax             ; BA10 AA
    lda $18         ; BA11 A5 18
    and #$07        ; BA13 29 07
    tay             ; BA15 A8
    iny             ; BA16 C8
    lda LBB0E,x     ; BA17 BD 0E BB
LBA1A:  
		asl a           ; BA1A 0A
		dey             ; BA1B 88
    bne LBA1A       ; BA1C D0 FC
    bcc LBA9B       ; BA1E 90 7B
		lda $70         ; BA20 A5 70
		sta $78B5       ; BA22 8D B5 78
		lda $71         ; BA25 A5 71
		sta $78B6       ; BA27 8D B6 78
		jsr getTarget2C ; BA2A 20 25 BC
		pha             ; BA2D 48
			and #$07        ; BA2E 29 07
			tax             ; BA30 AA
			lda $7EB8       ; BA31 AD B8 7E
			jsr flagTargetBit                   ; BA34 20 20 FD
			sta $7EB8       ; BA37 8D B8 7E
			ldy #$26        ; BA3A A0 26
			lda #$00        ; BA3C A9 00
			sta ($70),y     ; BA3E 91 70
			sta $24			; BA40 85 24
			sta $27			; BA42 85 27
			lda #$03        ; BA44 A9 03
			sta $25         ; BA46 85 25
		pla             ; BA48 68
		bmi LBA57       ; BA49 30 0C

		lda #$04        ; BA4B A9 04
		sta $24         ; BA4D 85 24
		lda #$0B        ; BA4F A9 0B
		sta $25         ; BA51 85 25
		lda #$FC        ; BA53 A9 FC
		sta $27         ; BA55 85 27
LBA57:  
			lda #$01        ; BA57 A9 01
			sta $21         ; BA59 85 21
			ldx $24         ; BA5B A6 24
			lda $25         ; BA5D A5 25
			jsr getBattleRandom                 ; BA5F 20 EF FB
			pha             ; BA62 48
			clc             ; BA63 18
LBA64:  
			adc $27         ; BA64 65 27
			sta $26         ; BA66 85 26
			pla             ; BA68 68
			ldx #$40        ; BA69 A2 40
			jsr mul8x8      ; BA6B 20 D6 FC
			clc             ; BA6E 18
			lda $1A         ; BA6F A5 1A
			adc #$75        ; BA71 69 75
			sta $70         ; BA73 85 70
			lda $1B         ; BA75 A5 1B
			adc #$75        ; BA77 69 75
			sta $71         ; BA79 85 71
			ldy #$01        ; BA7B A0 01
			lda ($70),y     ; BA7D B1 70
			and #$C0        ; BA7F 29 C0
			bne LBA57       ; BA81 D0 D4

			iny             ; BA83 C8
			lda ($70),y     ; BA84 B1 70
			and #$01        ; BA86 29 01
			bne LBA57       ; BA88 D0 CD

		ldx $26         ; BA8A A6 26
		lda #$00        ; BA8C A9 00
		jsr flagTargetBit                   ; BA8E 20 20 FD
		ldx $7EC1       ; BA91 AE C1 7E
		inx             ; BA94 E8
		sta $7EB8,x     ; BA95 9D B8 7E
		inc $7574       ; BA98 EE 74 75
LBA9B:  
    rts             ; BA9B 60
*/
}
```




