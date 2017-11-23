
# $35:b601 redrawColumn



### args:
+ [in] u8 x : col

### local variables:
+	$35:b636: windowInitParams[8]

### (pseudo-)code:
```js
{
	$3d = a = (--x) << 3;//$fd3f
	loadTileArrayForItemWindowColumn(first:$3d);	//$b48b
	x = ($63 - 1) << 1;
	$18 = $b636.x; x++;
	$19 = $b636.x;
	if ((a = $63) == 1) a = 1; $b631;
$b627:	if (a == 8) a = 2; $b631;
$b62f:	a = 0;
$b631:	$1a = a;
	return draw8LineWindow(left:$18, right:$19, borderFlag:$1a);
$b636:
}
```



