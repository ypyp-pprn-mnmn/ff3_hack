
# $3c:956f menu.upload_default_bg_attrs
> BGの属性テーブルをデフォルト値(FF)で初期化する。

### args:
none.

### callers:
+	`1E:9638:20 6F 95  JSR menu.upload_default_bg_attrs`
+	`1E:9767:20 6F 95  JSR menu.upload_default_bg_attrs`
+	`1E:9BBF:20 6F 95  JSR menu.upload_default_bg_attrs`
+	`1E:9ECC:20 6F 95  JSR menu.upload_default_bg_attrs`
+	`1E:A841:20 6F 95  JSR menu.upload_default_bg_attrs`
+	`1E:A8C3:20 6F 95  JSR menu.upload_default_bg_attrs`

### local variables:
none.

### notes:
all of calls are made right after callouts to `$3d:a685 menu.main.erase`.

### (pseudo)code:
```js
{
/*
    jsr thunk_await_nmi_by_set_handler  ; 956F 20 00 FF
    bit $2002   		; 9572 2C 02 20
    lda #$23    		; 9575 A9 23
    sta $2006   		; 9577 8D 06 20
    lda #$C0    		; 957A A9 C0
    sta $2006   		; 957C 8D 06 20
    lda #$FF   			; 957F A9 FF
    ldx #$40    		; 9581 A2 40
.L_9583:
		sta $2007   	; 9583 8D 07 20
		dex             ; 9586 CA
		bne .L_9583   	; 9587 D0 FA
    jmp menu.init_ppu  	; 9589 4C 9F 95
*/
$958c:
}
```

