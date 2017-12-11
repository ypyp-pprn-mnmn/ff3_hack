

# $3f:f3e4 textd.save_text_ptr
> Saves current text pointer (at $3e) to temporary store

### args:
+	in string* $3e: pointer to save
+	out string* $99: saved pointer

### callers:
+	`F0A4 20 E4 F3`
+	`F20D 20 E4 F3`
+	`F2D9 20 E4 F3`
+	`F334 20 E4 F3`

### local variables:
none.

### notes:

### (pseudo)code:
```js
{
/*
	lda     $3E                             ; F3E4 A5 3E
	sta     $99                             ; F3E6 85 99
	lda     $3F                             ; F3E8 A5 3F
	sta     $9A                             ; F3EA 85 9A
	rts                                     ; F3EC 60
*/
	[$99, $9a] = [$3e, $3f];
	return;
$f3ec:
}
```


