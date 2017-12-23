
# $3c:962f menu.jobs.main_loop
>メインメニューから「ジョブ」を選択したときに実行される、UIの処理を行うメインのループ。

### args:
+	[in] u8 $7f,x : character offset

### (pseudo)code:
```js
{
/*
    jsr .L_96BA   ; 962F 20 BA 96
    jsr menu.init_input_states      ; 9632 20 92 95
    jsr menu.main.erase             ; 9635 20 85 A6
    jsr menu.upload_default_bg_attrs    ; 9638 20 6F 95
    jsr menu.jobs.get_change_costs  ; 963B 20 85 AD
    lda #$00    ; 963E A9 00
    sta $78F0   ; 9640 8D F0 78
    sta <$A3     ; 9643 85 A3
    ldx #$0C    ; 9645 A2 0C
    jsr menu.draw_window_box        ; 9647 20 F1 AA
    lda #$48    ; 964A A9 48
    jsr menu.draw_view_of_buffered_string; 964C 20 7A A8
    ldx #$0D    ; 964F A2 0D
    jsr menu.draw_window_box        ; 9651 20 F1 AA
    lda #$49    ; 9654 A9 49
    jsr menu.draw_window_content    ; 9656 20 78 A6
    ldx #$0E    ; 9659 A2 0E
    jsr menu.draw_window_box        ; 965B 20 F1 AA
.L_965E:
    ldx #$0E    ; 965E A2 0E
    jsr menu.get_window_content_metrics ; 9660 20 A6 AA
    lda #$4A    ; 9663 A9 4A
    jsr menu.draw_view_of_buffered_string; 9665 20 7A A8
.L_9668:
    lda #$01    ; 9668 A9 01
    sta <$A2     ; 966A 85 A2
    jsr menu.render_cursor          ; 966C 20 CD A7
    lda #$08    ; 966F A9 08
    jsr menu.window1.get_input_and_update_cursor; 9671 20 A3 91
    jsr .L_9698   ; 9674 20 98 96
    lda <$25     ; 9677 A5 25
    bne .L_961C   ; 9679 D0 A1
    lda <$24     ; 967B A5 24
    beq .L_9668   ; 967D F0 E9
    jsr menu.accept_input_action    ; 967F 20 74 8F
    jsr .L_96A5   ; 9682 20 A5 96
    bcc .L_965E   ; 9685 90 D7
    lda #$70    ; 9687 A9 70
    jsr .L_96DA   ; 9689 20 DA 96
    lda <$20     ; 968C A5 20
    and #$80    ; 968E 29 80
    beq .L_965E   ; 9690 F0 CC
    jsr .L_AB8F   ; 9692 20 8F AB
    jmp .L_961C   ; 9695 4C 1C 96
*/
	$96ba();
	menu.init_input_states();	//$9592();
	menu.main.erase();	//$a685();
	menu.upload_default_bg_attrs();	//$956f();
	menu.jobs.get_change_costs();	//$ad85();
$963e:
	$a3 = $78f0 = 0;
	
	menu.draw_window_box({window_type:x = 0x0c});	//aaf1
	menu.draw_view_of_buffered_string({text_id:a = 0x48});	//$a87a

	menu.draw_window_box({window_type:x = 0x0d});
	menu.draw_window_content({text_id:a = 0x49});	//$a678

	menu.draw_window_box({window_type:x = 0x0e});
$965e:
	do {
		do {
			menu.get_window_content_metrics({window_type:x = 0x0e});	//$aaa6
			menu.draw_view_of_buffered_string({text_id:a = 0x4a});	//$a87a
$9668:
			do {
				$a2 = 1;
				menu.render_cursor();	//$a7cd();

				menu.window1.get_input_and_update_cursor({delta:a = 8});	//$91a3();
				$9698();
				if ($25 != 0) {
					return menu.jobs.on_close();	//$961c(); //bne 961c
				}
$967b:
			} while ($24 == 0); //beq 9668
$967f:
			menu.accept_input_action();	//$8f74();
			$96a5();
		} while (!carry); //bcc 965e
$9687:
		a = 0x70;
		$96da();
	} while (($20 & 0x80) == 0); //beq 965e
$9692:
	$ab8f();
	return menu.jobs.on_close();	//jmp $961c();
}
```




