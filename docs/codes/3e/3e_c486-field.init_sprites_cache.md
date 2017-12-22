
# $3e:c486 field.init_sprites_cache
> スプライト属性のキャッシュ($0200)をすべて0xF0で埋めて初期化する。

### args:
+	out u8 $26: ?, set to 0 on exit.
+	out SpriteAttributes $0200[0x40]: sprite cache, filled with 0xF0's on exit.
	which would mean:
		+00: Y is 240
		+01: tile number 240
		+02: flip x, flip y, behind background
		+03: X is 240

### callers:
+	`1E:93A8:20 86 C4  JSR field.init_sprites_cache`
+	`1E:A547:20 86 C4  JSR field.init_sprites_cache`
+	`1E:A685:20 86 C4  JSR field.init_sprites_cache` @ $3d:a685 menu.main.erase
+	`1E:A7AF:20 86 C4  JSR field.init_sprites_cache`
+	`1E:A7DA:20 86 C4  JSR field.init_sprites_cache`
+	`1E:AF36:20 86 C4  JSR field.init_sprites_cache`
+	`1E:B8FF:20 86 C4  JSR field.init_sprites_cache`
+	`1E:BA5C:20 86 C4  JSR field.init_sprites_cache`
+	`1E:BBE0:20 86 C4  JSR field.init_sprites_cache`
+	`1F:C093:20 86 C4  JSR field.init_sprites_cache`
+	`1F:C15C:20 86 C4  JSR field.init_sprites_cache`
+	`1F:D336:20 86 C4  JSR field.init_sprites_cache` @ $3e:d336 field.clear_all_sprites
+	`1F:D753:20 86 C4  JSR field.init_sprites_cache`
+	`1F:D7D1:20 86 C4  JSR field.init_sprites_cache`
+	`1F:E240:20 86 C4  JSR field.init_sprites_cache`

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    ldx #$3F    ; C486 A2 3F
    lda #$F0    ; C488 A9 F0
.L_C48A:
		sta $0200,x ; C48A 9D 00 02
		sta $0240,x ; C48D 9D 40 02
		sta $0280,x ; C490 9D 80 02
		sta $02C0,x ; C493 9D C0 02
		dex         ; C496 CA
		bpl .L_C48A ; C497 10 F1
    lda #$00    ; C499 A9 00
    sta <$26    ; C49B 85 26
    rts         ; C49D 60
*/
$c49e:
}
```

