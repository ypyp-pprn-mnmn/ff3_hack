
# $3d:a9a0 menu.savefile.build_file_menu
> 各スロットにある既存ファイルをウインドウごと描画し、メニュー項目として管理情報(at $7900)に設定する。

### args:
+	out u8 $62: file availability flags. msb denotes 1st file, lsb denotes 3rd.
+	out MenuItem $7900[4]:
	menu items describing each file menu
	and command menu on top right on the screen
+	out u8 $79f1: last valid y position of menu item (= 0x0c)

### callers:
+	$3d:a984 menu.savefile.build_menu

### local variables:


### notes:
write notes here

### (pseudo)code:
```js
{
/*
    clc             ; A9A0 18
    jsr menu.savefile.save_or_load_current_game_with_buffer; A9A1 20 18 AA
    lda #$00    ; A9A4 A9 00
    sta <$62     ; A9A6 85 62
    ldx #$11    ; A9A8 A2 11
    jsr menu.draw_window_box        ; A9AA 20 F1 AA
    lda #$64    ; A9AD A9 64
    jsr menu.savefile.draw_file_summary ; A9AF 20 E1 A9
    rol <$62     ; A9B2 26 62
    ldx #$12    ; A9B4 A2 12
    jsr menu.draw_window_box        ; A9B6 20 F1 AA
    lda #$68    ; A9B9 A9 68
    jsr menu.savefile.draw_file_summary ; A9BB 20 E1 A9
    rol <$62     ; A9BE 26 62
    ldx #$13    ; A9C0 A2 13
    jsr menu.draw_window_box        ; A9C2 20 F1 AA
    lda #$6C    ; A9C5 A9 6C
    jsr menu.savefile.draw_file_summary ; A9C7 20 E1 A9
    rol <$62     ; A9CA 26 62
    sec             ; A9CC 38
    jsr menu.savefile.save_or_load_current_game_with_buffer; A9CD 20 18 AA
    ldx #$0F    ; A9D0 A2 0F
.L_A9D2:
  	lda $AA3B,x ; A9D2 BD 3B AA
    sta $7900,x ; A9D5 9D 00 79
    dex             ; A9D8 CA
    bpl .L_A9D2   ; A9D9 10 F7
    lda #$0C    ; A9DB A9 0C
    sta $79F1   ; A9DD 8D F1 79
    rts             ; A9E0 60
*/
}
```

