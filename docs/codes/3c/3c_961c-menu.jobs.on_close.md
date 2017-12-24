
# $3c:961c menu.jobs.on_close
>「ジョブ」メニューを閉じるときの処理。

### args:
+	u8 in $7f: character index.
+	u8 out $78f0: byte offset of selected menu-item, set to 0x14 (= 6th entry) on exit.

```js
{
/*
    jsr menu.accept_input_action    ; 961C 20 74 8F
    lda #$14    ; 961F A9 14
    sta $78F0   ; 9621 8D F0 78
    lda <$7F     ; 9624 A5 7F
    ora #$0F    ; 9626 09 0F
    tax             ; 9628 AA
    jsr menu.call_recalc_battle_params   ; 9629 20 0B D1
    jmp menu.main.erase             ; 962C 4C 85 A6
*/
	menu.accept_input_action();	//$8f74();
	$78f0 = 0x14;
	x = $7f | 0x0f
	menu.call_recalc_character_params();	//$d10b();
	return menu.main.erase();	//$a685;
}
```




