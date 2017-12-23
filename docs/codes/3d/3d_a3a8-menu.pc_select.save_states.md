

# $3d:a3a8 menu.pc_select.save_states
> プレイヤーキャラ選択ウインドウの状態を(メニューの管理情報領域に)保存する。

### args:

#### in:
+	u8 $b4: ?
+	u8 $b5: ?
+	u8 $b6: ?
+	u8 $b7: ?
+	u8 $b8: ?

#### out:
+	u8 $79eb: = $b4
+	u8 $79ec: = $b5
+	u8 $79ed: = $b6
+	u8 $79ee: = $b7
+	u8 $79ef: = $b8

### callers:
+	`1E:9C1B:20 A8 A3  JSR menu.pc_select.init_states`
+	`1E:9E2B:20 A8 A3  JSR menu.pc_select.init_states`
+	`1E:9EEE:20 A8 A3  JSR menu.pc_select.init_states` @ $3c:9ec2 menu.items.main_loop
+	`1E:9F5E:20 A8 A3  JSR menu.pc_select.init_states`
+	`1E:AF8C:20 A8 A3  JSR menu.pc_select.init_states`
+	`1E:B0FC:20 A8 A3  JSR menu.pc_select.init_states`
+	`1E:B1FD:20 A8 A3  JSR menu.pc_select.init_states`
+	`1E:B5F8:20 A8 A3  JSR menu.pc_select.init_states`
+	`1E:B8B1:20 A8 A3  JSR menu.pc_select.init_states`
+	`1E:B9B7:20 A8 A3  JSR menu.pc_select.init_states`


### local variables:
+	yet to be investigated

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    lda <$B4     ; A3A8 A5 B4
    sta $79EB   ; A3AA 8D EB 79
    lda <$B5     ; A3AD A5 B5
    sta $79EC   ; A3AF 8D EC 79
    lda <$B6     ; A3B2 A5 B6
    sta $79ED   ; A3B4 8D ED 79
    lda <$B7     ; A3B7 A5 B7
    sta $79EE   ; A3B9 8D EE 79
    lda <$B8     ; A3BC A5 B8
    sta $79EF   ; A3BE 8D EF 79
    rts             ; A3C1 60
*/
}
```


