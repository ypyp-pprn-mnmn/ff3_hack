
# $3f:f83b field.restore_variables_from_battle_mode
> 戦闘モード用に退避した変数を復元する。

### args:
+	in u8 $7480[0xd0]: => $00
+	in u8 $7550[0x20]: => $e0
+	out u8 $00[0xd0]: <= $7480
+	out u8 $e0[0x20]: <= $7550

### notes:
address range $d0 to $df (inclusive) is utilized by sound driver.
this function is avoiding any operation on that range.

### code:
```js
{
	for (x = 0;x != 0xd0;x++) {
		$0000.x = $7480.x;
	}
	for (x = 0;x != 0xe0;x++) {
		$0000.x = $7470.x;
	}
}
```


