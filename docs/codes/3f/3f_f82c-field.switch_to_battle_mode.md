
# $3f:f82c field.switch_to_battle_mode
> フィールドモードの変数を退避し、その後PRG ROM bank $34をマップし利用可能にする。

### args:
no direct arguments.

### callers:
yet to be investigated.

### local variables:
none.

### notes:
processor registers A, X and Y are preserved. (as will be passed onto battle-mode function.)
A and X are explicitly saved at entry, but Y is also preserved as underlying functions don't change it.

### code:
```js
{
	push(a);
	push(x = a);
	saveFieldVars();	//$fb17();
	switch_16k_synchronized({bank: a = 0x1a});	//$fb87();
	x = pop();
	a = pop();
	return;
/*
    pha             ; F82C 48
    txa             ; F82D 8A
    pha             ; F82E 48
    jsr saveFieldVars               ; F82F 20 17 FB
    lda #$1A    ; F832 A9 1A
    jsr switch_16k_synchronized     ; F834 20 87 FB
    pla             ; F837 68
    tax             ; F838 AA
    pla             ; F839 68
	rts             ; F83A 60
*/
$f83b:
}
```


