
# $3e:c9a9 field::set_bg_attr_for_window


## args:
+	[in] u8 $37 :
+	[in] u8 $3c : palette entry count * 2
## code:
```js
{
	if ($37 == 0) { //bne c9b5
		x = $3c >> 1;
		x--;
		retun field::copyToVramWith_07d0();	//jmp cb6b
	}
$c9b5:
	return;
}
```




