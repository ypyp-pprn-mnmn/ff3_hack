
# $3d:af1f menu.stomach.open
> デブチョコボのメニューを開く。

### args:
+	yet to be investigated

### callers:
+	yet to be investigated

### local variables:
+	yet to be investigated

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    jsr .L_B1EB   ; AF1F 20 EB B1
    lda #$00    ; AF22 A9 00
    sta $2001   ; AF24 8D 01 20
    sta $78F0   ; AF27 8D F0 78
    sta $79F0   ; AF2A 8D F0 79
    sta $7AF0   ; AF2D 8D F0 7A
    jsr .L_DD06   ; AF30 20 06 DD
    jsr .L_F7BB   ; AF33 20 BB F7
    jsr field.init_sprites_cache    ; AF36 20 86 C4
    jsr thunk.await_nmi_by_set_handler  ; AF39 20 00 FF
    lda #$02    ; AF3C A9 02
    sta $4014   ; AF3E 8D 14 40
    jsr field.upload_all_palette_entries; AF41 20 08 D3
    jsr menu.init_ppu               ; AF44 20 69 B3
    lda #$3C    ; AF47 A9 3C
    sta <$57     ; AF49 85 57
    lda #$01    ; AF4B A9 01
    sta <$37     ; AF4D 85 37
    lda #$00    ; AF4F A9 00
    sta <$A3     ; AF51 85 A3
    sta <$A4     ; AF53 85 A4
    lda <$A0     ; AF55 A5 A0
    cmp #$FC    ; AF57 C9 FC
    bcc .L_AF68   ; AF59 90 0D
	jmp menu.stomach.main_loop      ; AF5B 4C 83 B3
*/
$af5e:
}
```

