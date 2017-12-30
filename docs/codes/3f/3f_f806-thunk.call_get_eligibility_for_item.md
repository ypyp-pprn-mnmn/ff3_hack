
# $3f:f806 thunk.call_get_eligibility_for_item
> $f817を呼び出すためのthunk.

### args:
+	in u8 A: item_id
+	in u8 X: byte offset of character to get eligiblity.

### callers:
+	`jsr .L_F806   ; D116 20 06 F8` @ $3e:d113 field.get_eligiblity_flags
+	`jsr .L_F806   ; D121 20 06 F8` @ $3e:d113 field.get_eligiblity_flags
+	`jsr .L_F806   ; D12C 20 06 F8` @ $3e:d113 field.get_eligiblity_flags
+	`jsr .L_F806   ; D136 20 06 F8` @ $3e:d113 field.get_eligiblity_flags
+	`1F:D18B:20 06 F8  JSR thunk.call_get_eligiblity_of_i` @ ?

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
	return field.call_get_eligibility_for_item(); // jmp .L_F817   ; F806 4C 17 F8
}
```

