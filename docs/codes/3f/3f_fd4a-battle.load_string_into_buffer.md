
# $3f:fd4a battle.load_string_into_buffer
> 文字列用のバッファ(7ad7)に指定のテキストをロードする。

### args:
+	[in] u8 A : sourceBank(per16k)
+	[in,out] u8 X : destOffset
+	[in] string* $18 : pointer to source text. 
+	[out] u8 $7ad7[] : dest
+	[out] u8 Y : len

### notes:
former name: copyTo_$7ad7_x_Until0. see also `$3f:fd60 battle.get_text_ptr`.

### code:
```js
{
	switchFirst2Banks(a);
	y = 0;
	do {
		a = $18[y];
		if (0 == a) break;	
		$7ad7.x = a; x++;
	} while (++y != 0);
$fd5a:
	switchFirst2Banks(a = 0x1a);
}
```


