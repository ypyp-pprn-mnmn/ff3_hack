
# $3f:f3ed textd.restore_text_ptr
> Restores text pointer previously saved with `$3f:f3e4 textd.save_text_ptr`.

### args:
+	out string* $3e: restored pointer
+	in string* $99: saved pointer previously saved with `$3f:f3e4 textd.save_text_ptr`.
+	in u8 $93: bank number which the text pointed to is stored

### callers:
+	`F342 20 ED F3`
+	`F0DB 20 ED F3`

### local variables:
none.

### notes:

### (pseudo)code:
```js
{
/*
	lda     $99                             ; F3ED A5 99
	sta     $3E                             ; F3EF 85 3E
	lda     $9A                             ; F3F1 A5 9A
	sta     $3F                             ; F3F3 85 3F
	lda     $93                             ; F3F5 A5 93
	jmp     call_switchFirst2Banks          ; F3F7 4C 03 FF
*/
}
```

