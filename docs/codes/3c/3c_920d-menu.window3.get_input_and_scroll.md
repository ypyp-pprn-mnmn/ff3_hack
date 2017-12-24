

# $3c:920d menu.window3.get_input_and_scroll
> パッド入力を取得し、必要に応じてウインドウのスクロール値を更新し、画面を更新する。

### args:
+	in u8 A: offset delta for up/down key
+	in,out u8 $7af0: byte offset of selected item (each menu item consists of 4-byte structure)
+	in u8 $7af1: last valid offset of the view

### callers:
+	yet to be investigated

### local variables:
+	u8 $05: offset delta for up/down key?
+	u8 $06: offset delta effective?

### notes:
unlike other siblings, this logic DOES render the screen.

### (pseudo)code:
```js
{
/*
    sta <$05     ; 920D 85 05
    sta <$06     ; 920F 85 06
    jsr menu.get_input_and_queue_SE ; 9211 20 75 91
    and #$0F    ; 9214 29 0F
    beq .L_9240   ; 9216 F0 28
    cmp #$04    ; 9218 C9 04
    bcs .L_9220   ; 921A B0 04
    ldx #$04    ; 921C A2 04
    stx <$06     ; 921E 86 06
.L_9220:
  	and #$05    ; 9220 29 05
    bne .L_9241   ; 9222 D0 1D
    lda $7AF0   ; 9224 AD F0 7A
    sec             ; 9227 38
    sbc <$06     ; 9228 E5 06
    bcs .L_923D   ; 922A B0 11
    adc <$05     ; 922C 65 05
    sta <$05     ; 922E 85 05
    jsr menu.items.load_render_params   ; 9230 20 75 90
    jsr field.scrollup_item_window  ; 9233 20 69 EB
    bcs .L_925A   ; 9236 B0 22
    jsr menu.items.save_render_params   ; 9238 20 3D 90
    lda <$05     ; 923B A5 05
.L_923D:
  	sta $7AF0   ; 923D 8D F0 7A
.L_9240:
  	rts             ; 9240 60
; ----------------------------------------------------------------------------
.L_9241:
  	lda $7AF0   ; 9241 AD F0 7A
    clc             ; 9244 18
    adc <$06     ; 9245 65 06
    bcs .L_924E   ; 9247 B0 05
    cmp $7AF1   ; 9249 CD F1 7A
    bcc .L_923D   ; 924C 90 EF
.L_924E:
  	sbc <$05     ; 924E E5 05
    sta <$05     ; 9250 85 05
    jsr menu.items.load_render_params   ; 9252 20 75 90
    jsr field.scrolldown_item_window    ; 9255 20 2D EB
    bcc .L_9261   ; 9258 90 07
.L_925A:
  	lda #$00    ; 925A A9 00
    sta <$47     ; 925C 85 47
    jmp .L_D529   ; 925E 4C 29 D5
*/
}
```


