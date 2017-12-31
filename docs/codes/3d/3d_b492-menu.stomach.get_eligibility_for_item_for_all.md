

# $3d:b492 menu.stomach.get_eligibility_for_item_for_all
> (デブチョコボのメニューで)指定したアイテムの装備可能フラグを取得し、各プレイヤーキャラクターのステータスに反映する。

### args:
+	in u8 A: item_id

### callers:
+	`1E:B44A:20 92 B4  JSR $B492` @ menu.stomach.main_loop
+	`1E:B476:20 92 B4  JSR $B492` @ menu.stomach.main_loop

### local variables:
+	u8 $7470[0x100]: variables utilized in menu-mode
+	u8 $7200[0x100]: variables utilized in battle-mode

### notes:
this function is observed to take long time to complete and is causing slowdown of rendering of the item window and sound playback.
specifically, it takes approximately 1.5 ppu frame per a call. (1 frame (262 scanlines) + 133 scanlines).
basically underlying functions are responsible for such a slowness,
but this function also pays cost to take extra care of buffer at $7470,
that is only utilized by stomach menu and thus underlying functions don't care much about.

### (pseudo)code:
```js
{
/*
	pha             ; B492 48
    ldx #$00    ; B493 A2 00
.L_B495:
    lda $7470,x ; B495 BD 70 74
    sta $7200,x ; B498 9D 00 72
    inx             ; B49B E8
    bne .L_B495   ; B49C D0 F7
    pla             ; B49E 68
    jsr .L_AEE3   ; B49F 20 E3 AE
    ldx #$00    ; B4A2 A2 00
.L_B4A4:
    lda $7200,x ; B4A4 BD 00 72
    sta $7470,x ; B4A7 9D 70 74
    inx             ; B4AA E8
    bne .L_B4A4   ; B4AB D0 F7
	rts             ; B4AD 60
*/
$b4ae:
}
```


