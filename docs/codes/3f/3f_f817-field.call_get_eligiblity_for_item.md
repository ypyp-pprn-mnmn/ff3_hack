
# $3f:f817 field.call_get_eligiblity_for_item
> 一時的に戦闘モードへ移行し、指定のキャラクターについて指定のアイテムの装備可否を `$34:8009` を呼び出すことによって計算する。

### args:
+	in u8 A: item_id
+	in u8 X: byte offset of character to get eligiblity.

### callers:
+	`jmp .L_F817   ; F806 4C 17 F8` @ $3f:f806 thunk.call_get_eligibility_for_item

### local variables:
none.

### notes:
this function takes approx 82-83 scanlines enough time to complete.
in which large amount of the time spent on saving/restoring variables.

### (pseudo)code:
```js
{
/*
    jsr .L_F82C   ; F817 20 2C F8
    jsr .L_8009   ; F81A 20 09 80
	jmp .L_F826   ; F81D 4C 26 F8
*/
}
```



