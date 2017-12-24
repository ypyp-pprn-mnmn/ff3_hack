

# $3d:a38e menu.party_summary.load_render_params
> (メニューの管理情報領域から)プレイヤーキャラ選択ウインドウの描画用パラメータをロードする。

### args:

#### in:
+	u8 $79eb: ?
+	u8 $79ec: sprite placement box top
+	u8 $79ed: sprite placement box left
+	u8 $79ee: sprite placement box bottom
+	u8 $79ef: sprite placement box right

#### out:
+	u8 $b4: = $79eb
+	u8 $b5: = $79ec
+	u8 $b6: = $79ed
+	u8 $b7: = $79ee
+	u8 $b8: = $79ef

### callers:
+	yet to be investigated

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    lda $79EB   ; A38E AD EB 79
    sta <$B4     ; A391 85 B4
    lda $79EC   ; A393 AD EC 79
    sta <$B5     ; A396 85 B5
    lda $79ED   ; A398 AD ED 79
    sta <$B6     ; A39B 85 B6
    lda $79EE   ; A39D AD EE 79
    sta <$B7     ; A3A0 85 B7
    lda $79EF   ; A3A2 AD EF 79
    sta <$B8     ; A3A5 85 B8
    rts             ; A3A7 60
*/
}
```


