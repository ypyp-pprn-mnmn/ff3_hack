>>
>>
>># $3d:b369 menu.init_ppu
>>> PPUの各レジスタを初期化し、制御フラグのキャッシュ(at $fd, $ff)にも設定する。
>>
>>### args:
>>+	out u8 $fd: ppu ctrl cache?
>>+	out u8 $ff: ppu ctrl cache.
>>
>>### callers:
>>+	`1E:AF44:20 69 B3  JSR $B369`
>>+	`1E:B393:20 69 B3  JSR $B369` @ $3d:b383 menu.stomach.main
>>
>>### local variables:
>>none.
>>
>>### notes:
>>this function is very similar to `$3c:959f menu.reset_ppu`.
>>the other one doesn't set internal cache values ($fd, $ff)
>>
>>### (pseudo)code:
>>```js
>>{
>>/*.L_B369:
>>    lda #$88    ; B369 A9 88
>>    sta <$FD    ; B36B 85 FD
>>    sta <$FF    ; B36D 85 FF
>>    sta $2000   ; B36F 8D 00 20
>>    lda #$00    ; B372 A9 00
>>    sta $2005   ; B374 8D 05 20
>>    sta $2005   ; B377 8D 05 20
>>    lda #$1E    ; B37A A9 1E
>>    sta $2001   ; B37C 8D 01 20
>>	rts         ; B37F 60
>>*/
>>}
>>```
>>
>>
________________________________________________________________________________
# $3d:b383 menu.stomach.main_loop
> デブチョコボに話しかけたときに実行される、UIの処理を行うメインのループ。

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
.L_B383:
    lda #$0F    ; B383 A9 0F
    sta $03DD   ; B385 8D DD 03
    lda #$27    ; B388 A9 27
    sta $03DE   ; B38A 8D DE 03
    jsr thunk.await_nmi_by_set_handler  ; B38D 20 00 FF
    jsr field.upload_all_palette_entries; B390 20 08 D3
    jsr menu.init_ppu               ; B393 20 69 B3
    jsr menu.clear_eligible_status_of_all_characters; B396 20 C3 AE
    lda #$51    ; B399 A9 51
    jsr menu.stomach.draw_message   ; B39B 20 F7 B5
    lda #$24    ; B39E A9 24
    jsr menu.stomach.draw_subcommands   ; B3A0 20 ED B5
    lda #$00    ; B3A3 A9 00
    sta <$A3     ; B3A5 85 A3
    sta <$A4     ; B3A7 85 A4
    sta <$B4     ; B3A9 85 B4
    sta $78F0   ; B3AB 8D F0 78
    lda #$01    ; B3AE A9 01
    sta <$A2     ; B3B0 85 A2
.L_B3B2:
    jsr menu.render_cursor          ; B3B2 20 CD A7
    lda #$04    ; B3B5 A9 04
    jsr menu.window1.get_input_and_update_cursor; B3B7 20 A3 91
    jsr menu.stomach.load_eligible_action_sprites; B3BA 20 8C 80
    lda <$25     ; B3BD A5 25
    bne .L_B380   ; B3BF D0 BF
    lda <$24     ; B3C1 A5 24
    beq .L_B3B2   ; B3C3 F0 ED
    jsr menu.accept_input_action    ; B3C5 20 74 8F
    lda $78F0   ; B3C8 AD F0 78
    cmp #$08    ; B3CB C9 08
    bcs .L_B380   ; B3CD B0 B1
    cmp #$04    ; B3CF C9 04
    beq .L_B419   ; B3D1 F0 46
    lda #$52    ; B3D3 A9 52
    jsr menu.stomach.draw_message   ; B3D5 20 F7 B5
    lda #$80    ; B3D8 A9 80
    sta <$B4     ; B3DA 85 B4
    ldx #$19    ; B3DC A2 19
    jsr menu.draw_window_box        ; B3DE 20 F1 AA
    lda #$3D    ; B3E1 A9 3D
    jsr menu.draw_window_content    ; B3E3 20 78 A6
    lda #$00    ; B3E6 A9 00
    sta $7AF0   ; B3E8 8D F0 7A
    lda #$01    ; B3EB A9 01
    sta <$A4     ; B3ED 85 A4
    jsr menu.items.save_render_params   ; B3EF 20 3D 90
.L_B3F2:
    jsr menu.render_cursor          ; B3F2 20 CD A7
    jsr menu.stomach.load_eligible_action_sprites; B3F5 20 8C 80
    lda #$08    ; B3F8 A9 08
    jsr menu.window3.get_input_and_scroll; B3FA 20 0D 92
    lda <$25     ; B3FD A5 25
    beq .L_B407   ; B3FF F0 06
.L_B401:
    jsr menu.accept_input_action    ; B401 20 74 8F
    jmp .L_B383   ; B404 4C 83 B3
; ----------------------------------------------------------------------------
.L_B407:
    lda <$24     ; B407 A5 24
    beq .L_B3F2   ; B409 F0 E7
    jsr menu.accept_input_action    ; B40B 20 74 8F
    jsr menu.stomach.store_item     ; B40E 20 AE B4
    bcs .L_B3F2   ; B411 B0 DF
    jsr menu.draw_item_select_window    ; B413 20 19 B6
    jmp .L_B3F2   ; B416 4C F2 B3
; ----------------------------------------------------------------------------
.L_B419:
    lda #$53    ; B419 A9 53
    jsr menu.stomach.draw_message   ; B41B 20 F7 B5
    lda #$80    ; B41E A9 80
    sta <$B4     ; B420 85 B4
    ldx #$19    ; B422 A2 19
    jsr menu.draw_window_box        ; B424 20 F1 AA
    jsr menu.stomach.build_content_text ; B427 20 70 B5
    lda #$18    ; B42A A9 18
    sta <$93     ; B42C 85 93
    lda #$01    ; B42E A9 01
    sta <$3E     ; B430 85 3E
    lda #$73    ; B432 A9 73
    sta <$3F     ; B434 85 3F
    jsr field.reflect_window_scroll ; B436 20 61 EB
    lda #$00    ; B439 A9 00
    sta $7AF0   ; B43B 8D F0 7A
    lda #$01    ; B43E A9 01
    sta <$A4     ; B440 85 A4
    jsr menu.items.save_render_params   ; B442 20 3D 90
    lda $7C00   ; B445 AD 00 7C
    beq .L_B44D   ; B448 F0 03
    jsr .L_B492   ; B44A 20 92 B4
.L_B44D:
    jsr menu.render_cursor          ; B44D 20 CD A7
    jsr menu.stomach.load_eligible_action_sprites; B450 20 8C 80
    ldx $7AF0   ; B453 AE F0 7A
    ldy $7A03,x ; B456 BC 03 7A
    lda $7C00,y ; B459 B9 00 7C
    pha             ; B45C 48
    lda #$08    ; B45D A9 08
    jsr menu.window3.get_input_and_scroll; B45F 20 0D 92
    ldx $7AF0   ; B462 AE F0 7A
    ldy $7A03,x ; B465 BC 03 7A
    pla             ; B468 68
    cmp $7C00,y ; B469 D9 00 7C
    beq .L_B479   ; B46C F0 0B
    jsr menu.clear_eligible_status_of_all_characters; B46E 20 C3 AE
    lda $7C00,y ; B471 B9 00 7C
    beq .L_B479   ; B474 F0 03
    jsr .L_B492   ; B476 20 92 B4
.L_B479:
    lda <$25     ; B479 A5 25
    beq .L_B480   ; B47B F0 03
    jmp .L_B401   ; B47D 4C 01 B4
; ----------------------------------------------------------------------------
.L_B480:
    lda <$24     ; B480 A5 24
    beq .L_B44D   ; B482 F0 C9
    jsr menu.accept_input_action    ; B484 20 74 8F
    jsr .L_B504   ; B487 20 04 B5
    bcs .L_B44D   ; B48A B0 C1
    jsr menu.draw_item_select_window    ; B48C 20 19 B6
    jmp .L_B44D   ; B48F 4C 4D B4
*/
$b492:
}
```
________________________________________________________________________________
>>
>># $3d:b4ae menu.stomach.store_item
>>> デブチョコボにアイテムを預ける。
>>
>>### args:
>>+	in u8 $7af0: byte offset into selected item in the menu.
>>+	in MenuItem $7a00[]
>>+	in,out u8 $60c0[0x20]: IDs of items in backpack
>>+	in,out u8 $60e0[0x20]: amounts of items in backpack
>>
>>### callers:
>>+	`1E:B40E:20 AE B4  JSR menu.stomach.store_item` @ $3d:b383 menu.stomach.main
>>
>>### local variables:
>>+	u8 $80: amount of item to be stored
>>+	u8 $8e: index (in backpatk) of item to be stored
>>
>>### notes:
>>write notes here
>>
>>### (pseudo)code:
>>```js
>>{
>>/*
>>    ldx $7AF0   ; B4AE AE F0 7A
>>	lda $7A02,x ; B4B1 BD 02 7A
>>	;;0x0F == CHAR.DUSTBOX
>>    cmp #$0F    ; B4B4 C9 0F
>>    beq .L_B4C3   ; B4B6 F0 0B
>>    lda $7A03,x ; B4B8 BD 03 7A
>>    sta <$8E     ; B4BB 85 8E
>>    tax             ; B4BD AA
>>    lda $60C0,x ; B4BE BD C0 60
>>    bne .L_B4C8   ; B4C1 D0 05
>>.L_B4C3:
>>    jsr menu.queue_SE_of_invalid_action ; B4C3 20 29 D5
>>    sec             ; B4C6 38
>>    rts             ; B4C7 60
>>; ----------------------------------------------------------------------------
>>.L_B4C8:
>>    cmp #$9A    ; B4C8 C9 9A
>>    bcc .L_B4D0   ; B4CA 90 04
>>    cmp #$A4    ; B4CC C9 A4
>>    bcc .L_B4C3   ; B4CE 90 F3
>>.L_B4D0:
>>    tay             ; B4D0 A8
>>    lda #$00    ; B4D1 A9 00
>>    sta <$80     ; B4D3 85 80
>>    lda $6300,y ; B4D5 B9 00 63
>>    cmp #$63    ; B4D8 C9 63
>>    bcc .L_B4E3   ; B4DA 90 07
>>        lda #$55    ; B4DC A9 55
>>        jsr menu.stomach.draw_message   ; B4DE 20 F7 B5
>>        clc             ; B4E1 18
>>        rts             ; B4E2 60
>>; ----------------------------------------------------------------------------
>>.L_B4E3:
>>    adc $60E0,x ; B4E3 7D E0 60
>>    cmp #$64    ; B4E6 C9 64
>>    bcc .L_B4F0   ; B4E8 90 06
>>    sbc #$63    ; B4EA E9 63
>>    sta <$80     ; B4EC 85 80
>>    lda #$63    ; B4EE A9 63
>>.L_B4F0:
>>    sta $6300,y ; B4F0 99 00 63
>>    lda <$80     ; B4F3 A5 80
>>    sta $60E0,x ; B4F5 9D E0 60
>>    bne .L_B4FD   ; B4F8 D0 03
>>    sta $60C0,x ; B4FA 9D C0 60
>>.L_B4FD:
>>    lda #$54    ; B4FD A9 54
>>    jsr menu.stomach.draw_message   ; B4FF 20 F7 B5
>>    clc             ; B502 18
>>    rts             ; B503 60
>>*/
>>}
>>```
>>
