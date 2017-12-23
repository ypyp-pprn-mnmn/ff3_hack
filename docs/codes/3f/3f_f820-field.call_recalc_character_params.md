
# $3f:f820 field.call_recalc_character_params
> 一時的に戦闘モードへ移行し、各種ステータス値を `$34:8006` を呼び出すことによって計算する。

### args:
+	in u8 X: character index.

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
    jsr .L_F82C   ; F820 20 2C F8
	;;here bank 34-35.
    jsr .L_8006   ; F823 20 06 80
    pha             ; F826 48
    jsr restoreFieldVariables       ; F827 20 3B F8
    pla             ; F82A 68
    rts             ; F82B 60
*/
}
```

