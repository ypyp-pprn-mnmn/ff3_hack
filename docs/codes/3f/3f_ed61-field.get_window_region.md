
# $3f:ed61 field::get_window_region
>マップのスクロールも考慮して、ウインドウの描画に用いる各種値(座標etc)を取得する。
>あわせて、ウインドウ領域の内外に基づいてオブジェクトの属性を変更する。

### args:

#### in:
+	u8 X: window_type (0...4)
	-	0: object's message?
	-	1: choose dialog (Yes/No) (can be checked at INN)
	-	2: choose item dialog (which is shown to use item on object, when hit 'B' in front of object)
	-	3: Gil (can be checked at INN)
	-	4: floor name
+	u8 $29: floor_scroll_x (in map chip (i.e., 16x16) unit)
+	u8 $2f: floor_scroll_y (in map chip (i.e., 16x16) unit)
+	u8 $37: in_menu_mode

#### out:

##### the following metrics are calculated as relative to *BG* origin.
i.e., it is an absolute offset. the scroll value of floor is accounted within.

+	u8 $38: window box left, with border included
+	u8 $39: window box top, with border included

##### the following metrics are calculated as relative to *viewport* origin.
i.e., it is an relative offset. the scroll value of floor is NOT accounted within.

+	u8 $3c: window box width, with border included.
+	u8 $3d: window box height, with border included.
+	u8 $97: cursor origin x. (= window box left - 1, if ignoring the scroll value)
+	u8 $98: cursor origin y. (= window bot top + 2, if ignoring the scroll value)
+	u8 $b5: sprite placement box top. (= window box top + 1, if ignoring the scroll value)
+	u8 $b6: sprite placement box left. (= window box left, if ignoring the scroll value)
+	u8 $b7: sprite placement box bottom. (top + window box height - 3)
+	u8 $b8: sprite placement box right. (left + window box width - 1)

### callers:
+	$3f:ed02 field::draw_window_box

### notes:
1.	to reflect changes in screen those made by `field.hide_sprites_under_window`,
	which is called from within this function,
	caller must upload sprite attr onto OAM, such as:

		lda #2
		sta $4014	;DMA
2.	this logic is very simlar to `$3d$aabc menu.get_window_metrics`.
	the difference is:
	-	A) this logic takes care of wrap-around unlike the other one, which does not.
	-	B) target window and the address of table where the corresponding metrics defined at

### code:
```js
{
	if ($37 == 0) { //bne edb1
		a = $b6 = $edb2.x
		$97 = a - 1;
		$98 = $b5 = a = $edb7.x + 2;
		$b5--;
		$38 = (($29 << 1) + $edb2.x) & 0x3f;
		$39 = (($2f << 1) + $edb7.x) % 0x1e;
		a = $3c = $edbc.x;
		a = $b8 = $b6 + a;
		$b8--;
		a = $3d = $edc1.x;
		$b7 = a + $b5 - 3;
		$ec18();	//field_hide_sprites_around_window
	}
$edb1:
	return;
}
```




