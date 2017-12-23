
# $3d:a984 menu.savefile.build_menu
> セーブメニューを構築する。タイトル、メッセージ、各ゲームデータの内容を描画し、メニュー項目を初期化する。

### args:
no direct arguments. (functions called within this function may have arguments).

### callers:
+	$3d:a897 menu.savefile.main_loop

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
	;; title text. (window sit on top-left of the screen)
    ldx #$0F    ; A984 A2 0F
    jsr menu.draw_window_box        ; A986 20 F1 AA
    lda #$38    ; A989 A9 38
    jsr menu.stream_window_content  ; A98B 20 6B A6
	;; body.
    jsr menu.savefile.build_file_menu   ; A98E 20 A0 A9
	;; message text (window sit on top-right of the screen)
    lda #$4B    ; A991 A9 4B
    jmp menu.savefile.draw_message   ; A993 4C 96 A9
*/
}
```

