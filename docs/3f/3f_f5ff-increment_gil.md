
# $3f:f5ff increment_gil


## args:
+	[in] u24 $80 : gil
## callers:
+	$3d:b1c2 @ floor::shop::
+	$3f:f5bb @ floor::getTreasure
## code:
```js
{
	$601c,$601d,$601e += $80,81,82;
	if ($601e > #98) { //bcs f630 bcc f63f
$f630:
		$601c,$601d,$601e = 0x98967F; //9999999
	}
$f63f:
	return;
}
```



