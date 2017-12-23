
# $3f:f44b menu.erase_message_area
> 各種メニューでメッセージ用のウインドウを配置する領域((9,2)-(31,6))を消去する。

### args:
none.

### callers:
+	`1E:AA8E:20 4B F4  JSR $F44B` @ $3d:aa8e menu.items.erase_message
+	yet to be investigated

### local variables:
+	yet to be investigated

### notes:
write notes here

### (pseudo)code:
```js
{
/*
	lda #$02        	; F44B A9 02
	sta <.window_top    ; F44D 85 39
	sta <.offset_y      ; F44F 85 3B
	lda #$09        	; F451 A9 09
	sta <.window_left   ; F453 85 38
	lda #$16        	; F455 A9 16
	sta <.window_width  ; F457 85 3C
	lda #$04        	; F459 A9 04
	sta <.window_height ; F45B 85 3D
	lda #$02        	; F45D A9 02
	bne menu.erase_box_from_bottom    ; F45F D0 19
*/
$f461:
}
```




