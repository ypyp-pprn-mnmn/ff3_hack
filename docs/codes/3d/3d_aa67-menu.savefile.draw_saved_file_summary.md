
# $3d:aa67 menu.savefile.draw_saved_file_summary
> 「セーブ」メニューで選択されたファイルの情報を描画する。

### args:
+	in u8 $79f0: cursor pos y

### (pseudo)code:
```js
{
/*
    lda #$00    ; AA67 A9 00
    sta <$A3     ; AA69 85 A3
    sta <$A2     ; AA6B 85 A2
    jsr menu.render_cursor          ; AA6D 20 CD A7
    lda $79F0   ; AA70 AD F0 79
    lsr a       ; AA73 4A
    lsr a       ; AA74 4A
    and #$03    ; AA75 29 03
    pha             ; AA77 48
    clc             ; AA78 18
    adc #$11    ; AA79 69 11
    tax             ; AA7B AA
    jsr menu.draw_window_box        ; AA7C 20 F1 AA
    lda #$25    ; AA7F A9 25
    jsr menu.stream_window_content  ; AA81 20 6B A6
    pla             ; AA84 68
    clc             ; AA85 18
    adc #$01    ; AA86 69 01
    jsr menu.select_pc.put_pc_sprites   ; AA88 20 00 80
    jmp menu.render_cursor          ; AA8B 4C CD A7
*/
	$a3 = $a2 = 0;
	menu.render_cursor();	//$a7cd();
	push(a = (($79f0 >> 2) & 3));
	menu.draw_window_box({window_id:x = a + 0x11});	//aaf1();
	menu.stream_window_content({text_id:a = 0x25});	//$a66b();
	a = pop();
	a++;
	menu.select_pc.put_pc_sprites({char_index: a});	//$8000();
	return menu.render_cursor();	//jmp $a7cd();
$aa8e:
}
```




