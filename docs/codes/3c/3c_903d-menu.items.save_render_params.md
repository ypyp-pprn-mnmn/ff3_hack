
# $3c:903d menu.items.save_render_params
> アイテムウインドウ($7a00で管理)の描画用パラメータを(管理用の領域に)保存する。

### args:

#### in:
+	string* $1c: pointer to buffer
+	u8 $38: window left
+	u8 $39: window top
+	u8 $3c: window width
+	u8 $3d: window height
+	string* $3e: pointer to source text
+	u8 $93: bank number of source text
+	u8 $97: cursor stop offset x
+	u8 $98: cursor stop offset y

#### out:
+	string* $7af4: pointer to source text
+	u8 $7af7: bank number of source text
+	u8 $7af8: window left
+	u8 $7af9: window top
+	u8 $7afa: cursor stop offset x
+	u8 $7afb: cursor stop offset y
+	u8 $7afc: window width
+	u8 $7afd: window height
+	string* $7afe: pointer to buffer

### callers:
+	`1E:8DF8:20 3D 90  JSR menu.items.init_states`
+	`1E:9238:20 3D 90  JSR menu.items.init_states`
+	`1E:9261:20 3D 90  JSR menu.items.init_states`
+	`1E:9C14:20 3D 90  JSR menu.items.init_states`
+	`1E:9EEB:20 3D 90  JSR menu.items.init_states` @ $3c:9ec2 menu.items.main_loop
+	`1E:B0F5:20 3D 90  JSR menu.items.init_states`
+	`1E:B3EF:20 3D 90  JSR menu.items.init_states`
+	`1E:B442:20 3D 90  JSR menu.items.init_states`
+	`1E:B8AA:20 3D 90  JSR menu.items.init_states`

### local variables:
none.

### notes:
`$3c:9075` does the opposite of this logic.

### (pseudo)code:
```js
{
/*
    lda <$38     ; 903D A5 38
    sta $7AF8   ; 903F 8D F8 7A
    lda <$39     ; 9042 A5 39
    sta $7AF9   ; 9044 8D F9 7A
    lda <$97     ; 9047 A5 97
    sta $7AFA   ; 9049 8D FA 7A
    lda <$98     ; 904C A5 98
    sta $7AFB   ; 904E 8D FB 7A
    lda <$3C     ; 9051 A5 3C
    sta $7AFC   ; 9053 8D FC 7A
    lda <$3D     ; 9056 A5 3D
    sta $7AFD   ; 9058 8D FD 7A
    lda <$93     ; 905B A5 93
    sta $7AF7   ; 905D 8D F7 7A
    lda <$1C     ; 9060 A5 1C
    sta $7AFE   ; 9062 8D FE 7A
    lda <$1D     ; 9065 A5 1D
    sta $7AFF   ; 9067 8D FF 7A
    lda <$3E     ; 906A A5 3E
    sta $7AF4   ; 906C 8D F4 7A
    lda <$3F     ; 906F A5 3F
    sta $7AF5   ; 9071 8D F5 7A
    rts             ; 9074 60
*/
$9075:
}
```


