

# $3f:f826 field.back_to_field_mode_with_result
> 一時的に移行していた戦闘モードからフィールドモードに戻る。

### args:
+	in u8 A: result value from battle-mode function

### callers:
+	`jmp .L_F826   ; F81D 4C 26 F8` @ $3f:f817 field.call_get_eligiblity_for_item
+	`jsr .L_8006   ; F823 20 06 80` (fall through) @ $3f:f820 field.call_recalc_character_params

### local variables:
+	none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    pha             ; F826 48
    jsr restoreFieldVariables       ; F827 20 3B F8
    pla             ; F82A 68
	rts             ; F82B 60
*/
$f82c:
}
```


