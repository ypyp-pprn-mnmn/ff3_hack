
# $3e:d10b menu.call_recalc_character_params
> 戦闘用の各種ステータス値を `$34:8006` を呼び出すことによって計算する。

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
    jsr thunk.call_recalc_battle_params   ; D10B 20 03 F8
    lda #$3C    ; D10E A9 3C
    jmp call_switchFirst2Banks      ; D110 4C 03 FF
*/
}
```

