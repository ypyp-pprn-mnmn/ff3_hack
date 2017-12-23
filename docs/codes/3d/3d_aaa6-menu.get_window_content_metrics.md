
# $3d:aaa6 menu.get_window_content_metrics
> 各種メニューウインドウのコンテンツ領域のメトリック(サイズ・位置)を取得する。

### args:

#### in:
+	u8 X: window_id

#### out:
+   u8 $38: box left
+	u8 $39: box top
+   u8 $3c: box width
+   u8 $3d: box height
+   u8 $97: cursor stop offset x
+   u8 $98: cursor stop offset y

### notes:

### (pseudo)code:
```js
{
/*
    jsr menu.get_window_metrics     ; AAA6 20 BC AA
    inc <$38     ; AAA9 E6 38
    inc <$39     ; AAAB E6 39
    lda <$3C     ; AAAD A5 3C
    sec             ; AAAF 38
    sbc #$02    ; AAB0 E9 02
    sta <$3C     ; AAB2 85 3C
    lda <$3D     ; AAB4 A5 3D
    sec             ; AAB6 38
    sbc #$02    ; AAB7 E9 02
    sta <$3D     ; AAB9 85 3D
    rts             ; AABB 60
*/
	menu.get_window_metrics();	//aabc
	$38++; $39++;
	$3c -= 2;
	$3d -= 2;
	return;
}
```




