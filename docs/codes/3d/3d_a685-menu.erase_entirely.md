

# $3d:a685 menu.erase_entirely
> スプライトを画面とキャッシュから消去し、その後画面全体を消去する。

### args:
none.

### callers:
+	`1E:9635:20 85 A6  JSR menu.main.erase`
+   `1E:9764:20 85 A6  JSR menu.main.erase`
+   `1E:9921:20 85 A6  JSR menu.main.erase` *
+   `1E:9BBC:20 85 A6  JSR menu.main.erase`
+   `1E:9EC9:20 85 A6  JSR menu.main.erase`
+   `1E:A529:20 85 A6  JSR menu.main.erase` *
+   `1E:A646:20 85 A6  JSR menu.main.erase` *
+   `1E:A83E:20 85 A6  JSR menu.main.erase`
+   `1E:A8C0:20 85 A6  JSR menu.main.erase`
+   `1E:B895:20 85 A6  JSR menu.main.erase` *

(*): calls that is not paired with $956f.

### local variables:
none.

### notes:
many callers (6 out of 10) made this call right before a callout to $956f.

### (pseudo)code:
```js
{
/*
    jsr field.init_sprites_cache   		; A685 20 86 C4
    jsr thunk_await_nmi_by_set_handler  ; A688 20 00 FF
    lda #$02    				        ; A68B A9 02
    sta $4014   				        ; A68D 8D 14 40
    jsr menu.init_ppu			        ; A690 20 9F 95
    jmp menu.erase_box_1e_x_1c          ; A693 4C 65 F4
*/
$a696:
}
```



