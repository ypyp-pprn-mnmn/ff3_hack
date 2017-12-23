

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

### callers:
+   `1E:9660:20 A6 AA  JSR $AAA6` @ $3c:962f menu.jobs.main_loop
+   `1E:9791:20 A6 AA  JSR menu.get_window_content_metric` @ $3c:9761 menu.magic.main_loop
+   `1E:A334:20 A6 AA  JSR menu.get_window_content_metric` @ $3d:a332 menu.party_summary.draw_content
+   `1E:B9BC:20 A6 AA  JSR menu.get_window_content_metric` @ ?
+   `1F:C02B:20 A6 AA  JSR menu.get_window_content_metric` @ ?

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





