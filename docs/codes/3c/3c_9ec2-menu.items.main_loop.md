
# $3c:9ec2 menu.items.main_loop
> メニューから「アイテム」を選択したときに実行され、UIの処理を行うメインのループ。

### args:
+	yet to be investigated

### callers:
+	$3d:a52f menu.main_loop

### local variables:
+	yet to be investigated

### notes:
-	the window lists backpack items is using:
	-	window type #6
	-	dialog handler #3 (structure at $7a00 initializied with charcode 0x17).
-	the window lists player characters for items to be targeted is using:
	-	window type #7
	-	dialog handler #2 (at $7900)

### (pseudo)code:
```js
{
/*
menu.items.main_loop:
    jsr menu.init_input_states      ; 9EC2 20 92 95
    lda #$80    ; 9EC5 A9 80
    sta <$B4     ; 9EC7 85 B4
    jsr menu.main.erase             ; 9EC9 20 85 A6
    jsr menu.upload_default_bg_attrs    ; 9ECC 20 6F 95
    jsr menu.pc_select.draw_window  ; 9ECF 20 28 A3
    lda #$00    ; 9ED2 A9 00
    sta <$A2     ; 9ED4 85 A2
    sta <$A3     ; 9ED6 85 A3
    lda #$01    ; 9ED8 A9 01
    sta <$A4     ; 9EDA 85 A4
    lda #$00    ; 9EDC A9 00
    sta $7AF0   ; 9EDE 8D F0 7A
    ldx #$06    ; 9EE1 A2 06
    jsr menu.draw_window_box        ; 9EE3 20 F1 AA
    lda #$3D    ; 9EE6 A9 3D
    jsr menu.draw_window_content    ; 9EE8 20 78 A6
    jsr menu.items.save_render_params   ; 9EEB 20 3D 90
    jsr menu.pc_select.save_states  ; 9EEE 20 A8 A3
    ldx #$05    ; 9EF1 A2 05
    jsr menu.draw_window_box        ; 9EF3 20 F1 AA
    lda #$35    ; 9EF6 A9 35
    jsr menu.stream_window_content  ; 9EF8 20 6B A6
    jsr menu.pc_select.load_states  ; 9EFB 20 8E A3
.L_9EFE:
	jsr menu.render_cursor			; 9EFE 20 CD A7
  	lda #$08    ; 9F01 A9 08
    jsr menu.window3.get_input_and_scroll; 9F03 20 0D 92
    lda #$03    ; 9F06 A9 03
    jsr menu.select_pc.put_pc_sprites   ; 9F08 20 00 80
    lda <$25     ; 9F0B A5 25
    bne menu.items.on_close         ; 9F0D D0 AD
    lda <$24     ; 9F0F A5 24
    beq .L_9EFE   ; 9F11 F0 EB
    jsr menu.accept_input_action    ; 9F13 20 74 8F
    lda #$02    ; 9F16 A9 02
    sta <$A3     ; 9F18 85 A3
    sta <$A4     ; 9F1A 85 A4
    jsr menu.items.clone_for_2nd_selection   ; 9F1C 20 63 A3
    lda $7AF0   ; 9F1F AD F0 7A
    sta $79F0   ; 9F22 8D F0 79
    tax             ; 9F25 AA
    lda $7A02,x ; 9F26 BD 02 7A
    cmp #$0F    ; 9F29 C9 0F
    bne .L_9F31   ; 9F2B D0 04
    lda #$FF    ; 9F2D A9 FF
    bne .L_9F34   ; 9F2F D0 03
.L_9F31:
  	lda $7A03,x ; 9F31 BD 03 7A
.L_9F34:
  	sta <$8E     ; 9F34 85 8E
    lda #$00    ; 9F36 A9 00
    sta $79F2   ; 9F38 8D F2 79
.L_9F3B:
 	jsr menu.render_cursor          ; 9F3B 20 CD A7
    lda #$08    ; 9F3E A9 08
    jsr menu.window3.get_input_and_scroll; 9F40 20 0D 92
    lda #$03    ; 9F43 A9 03
    jsr menu.select_pc.put_pc_sprites   ; 9F45 20 00 80
    lda <$25     ; 9F48 A5 25
    beq .L_9F5A   ; 9F4A F0 0E
    jsr menu.accept_input_action    ; 9F4C 20 74 8F
    lda #$00    ; 9F4F A9 00
    sta <$A3     ; 9F51 85 A3
    lda #$01    ; 9F53 A9 01
    sta <$A4     ; 9F55 85 A4
    jmp .L_9EFE   ; 9F57 4C FE 9E
; ----------------------------------------------------------------------------
.L_9F5A:
  	lda <$24     ; 9F5A A5 24
    beq .L_9F3B   ; 9F5C F0 DD
;; 2nd item has just selected.
    jsr menu.pc_select.save_states  ; 9F5E 20 A8 A3
    jsr .L_A349   ; 9F61 20 49 A3
    jsr menu.accept_input_action    ; 9F64 20 74 8F
    lda #$00    ; 9F67 A9 00
    sta <$A3     ; 9F69 85 A3
    sta <$B4     ; 9F6B 85 B4
    lda #$01    ; 9F6D A9 01
    sta <$A4     ; 9F6F 85 A4
    jsr .L_9FA5   ; 9F71 20 A5 9F
    php             ; 9F74 08
    jsr menu.pc_select.load_states  ; 9F75 20 8E A3
    jsr .L_A356   ; 9F78 20 56 A3
    plp             ; 9F7B 28
    bcs .L_9EFE   ; 9F7C B0 80
    jsr menu.items.erase_message   ; 9F7E 20 8E AA
    jsr .L_A356   ; 9F81 20 56 A3
    jsr menu.items.load_render_params   ; 9F84 20 75 90
    jsr menu.pc_select.load_states  ; 9F87 20 8E A3
    lda <$1C     ; 9F8A A5 1C
    sta <$3E     ; 9F8C 85 3E
    lda <$1D     ; 9F8E A5 1D
    sta <$3F     ; 9F90 85 3F
    jsr field.reflect_window_scroll ; 9F92 20 61 EB
    jsr menu.init_input_states      ; 9F95 20 92 95
    lda #$00    ; 9F98 A9 00
    sta <$A3     ; 9F9A 85 A3
    sta <$A2     ; 9F9C 85 A2
    lda #$01    ; 9F9E A9 01
    sta <$A4     ; 9FA0 85 A4
    jmp .L_9EFE   ; 9FA2 4C FE 9E
*/
}
```
