
# $3f:ff17 switch_2banks
>Switches PRG banks mapped to first two 8k pages ($8000-$BFFF) to the given consecutive banks.

### args:
+	in u8 A: basebank (per 8k)

### callers:
+	$3f:ff03 thunk.switch_2banks: it is an only caller of this function.

### notes:
processor registers X and Y are unaffected and preserved across calls.
some status flags are affected but in a manner expectible.
specifically, status flags are affected in the following way:

### processor flags:
+	carry: usually 0. this is the result of addition (bank number + 1) performed in this logic. so as long as caller supplies valid bank number (00-3f), it is safe to assume this to be 0 as carry never happen in that range.
+	zero: usually 0 as long as caller supplies valid bank number (00-3f).
+	negative: depends on the bank number given, usually 0 as valid bank number fall in positibe range (00-3F.)
rest are unaffected.

### code:
```js
{
	push(a);
	switch_1st_bank();	//$ff0c();
	pop(a);
	a += 1;
$ff1f:
	return switch_2nd_bank();	//$ff1f (fall through)
}
```

**fall through**

