


# $3d:aa18 menu.savefile.save_or_load_current_game_with_buffer
>現在プレイ中のゲームの状態データ(0x400 bytes at $6000)をバッファ($7400)へコピーするか、もしくはバッファのデータから復帰する。

### args:

#### in:
+	bool carry: save(0) or load(1)
+	u8 $6000[0x400]: current game states (if carry == 0)
+	u8 $7400[0x400]: copied states (if carry == 1)

#### out:
+	u8 $6000[0x400]: current game states (if carry == 1)
+	u8 $7400[0x400]: copied states (if carry == 0)

### callers:
+	yet to be investigated

### local variables:
+	ptr $80 : source data ($6000)
+	ptr $82 : dest data ($7400)

### notes:
savemenu calls this logic before and after rendering each file's content, to keep current game state.

### (pseudo)code:
```js
{
/*
	lda     #$00        ; AA18 A9 00
	tay                 ; AA1A A8
	sta     $80         ; AA1B 85 80
	sta     $82         ; AA1D 85 82
	lda     #$60        ; AA1F A9 60
	sta		$81
	lda		#$74
	sta		$83
	bcs     LAA06       ; AA27 B0 DD
LAA29:
	lda     ($80),y     ; AA29 B1 80
	sta     ($82),y     ; AA2B 91 82
	iny                 ; AA2D C8
	bne     LAA29       ; AA2E D0 F9
	inc     $81         ; AA30 E6 81
	inc     $83         ; AA32 E6 83
	lda     $81         ; AA34 A5 81
	and     #$03        ; AA36 29 03
	bne     LAA29       ; AA38 D0 EF
	rts                 ; AA3A 60
*/
}
```



