
# $3e:d113 field.get_eligibility_flags
> 指定したアイテムの装備可能フラグを各プレイヤーキャラクターごとに1bitで表すようにまとめた値を取得する。

### args:
+	in u8 A: item_id
+	out u8 $80: eligibility flags for characters,
	where bit 3 denotes character #0, bit2 for char #1, and so forth.

### callers:
+	`jsr .L_D113   ; AEE3 20 13 D1` @ $3d:aee3 menu.get_eligibility_of_item_for_all

### local variables:
none.

### notes:
see also:
    `$34:8043 battle.character.is_eligible_for_item`,
    `$35:b8fd isPlayerAllowedToUseItem`,
    `$3f:fd8b battle.map_user_type_to_eligibility_flags`

### (pseudo)code:
```js
{
/*
    pha             ; D113 48
    ldx #$00    ; D114 A2 00
    jsr .L_F806   ; D116 20 06 F8
    cmp #$01    ; D119 C9 01
    rol <$80     ; D11B 26 80
    pla             ; D11D 68
    pha             ; D11E 48
    ldx #$40    ; D11F A2 40
    jsr .L_F806   ; D121 20 06 F8
    cmp #$01    ; D124 C9 01
    rol <$80     ; D126 26 80
    pla             ; D128 68
    pha             ; D129 48
    ldx #$80    ; D12A A2 80
    jsr .L_F806   ; D12C 20 06 F8
    cmp #$01    ; D12F C9 01
    rol <$80     ; D131 26 80
    pla             ; D133 68
    ldx #$C0    ; D134 A2 C0
    jsr .L_F806   ; D136 20 06 F8
    cmp #$01    ; D139 C9 01
    rol <$80     ; D13B 26 80
    lda #$3C    ; D13D A9 3C
	jmp thunk.switch_2banks         ; D13F 4C 03 FF
*/
}
```

