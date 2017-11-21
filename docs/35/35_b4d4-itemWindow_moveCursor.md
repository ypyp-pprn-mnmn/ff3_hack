
# $35:b4d4 itemWindow_moveCursor

<summary></summary>

## args:
+	[in] u8 $62 : cursor row index (0-3)
+	[in] u8 $63 : cursor col index (0-7)
## (pseudo-)code:
```js
{
	a = #a8;
	for (x = $62; x != 0;x--) {
$b4db:		a += #10;
	}
$b4e0:
	$1c = a;
	if ($66 == (a = $63)) a = #8;
$b4ec:	else a = #80;
$b4ee:	$1d = a;
	return tileSprites2x2(index:$1a = 0, top:$1c, right:$1d );	//$34:892e()
$b4f7:
}
```



