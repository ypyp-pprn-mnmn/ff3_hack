
# $33:bd45 updateCharacterPos

### args:
+	[in] u8 x : charIndex
+	[in] $7d7d,7cf4
+	[in] $7d7f[4] : goal coords
+	[out] $c0[4],$c4[4] = {x,y}

### code:
```js
{
	if ((a = $7d7d) == 0) {
		$7e = 0;
		$7f = #ff;
	} else {
$bd55
		$7e = 1;
		$7f = #80;
	}
$bd5d
	if ($c0.x== $7d7f.x) 
$bd64		return;
$bd65:
	y = x << 1;
	a = $7d9b.y & 5;
	if (a == 0) $bdbd
$bd6f:	if (0 == (a & 4)) $bd94
$bd73:	//a == 5 or 4
	y = $7cf4 & 7
	$c4.x += $bde9.y;
	$7d83.x = $bdf1.y | $7f;
	$c0.x += ($7e + $7e);
	return;
$bd94:	//$7d9b.y == 1
	$7d83.x = (($7cf4 & 4) >> 2) + #0a;
	if (0 == (a = $7dc1.x)) bdb5;
bda6:
	a = $7d9b.y & 8;
	if (0 == a) bdb5;
	$7d83 ^= #80;
bdb5:
	$c0 += $7e;
bdbc:	
	return;
$bdbd:	//$7d9b.y & 5 == 0
	$7d83.x = (($7cf4 & 4) >> 2) + 1;
	if ($7dc1.x != 0) $bdde
	a = $7d9b.y & 8;
	if (a == 0) $bdde
	$7d83.x ^= #80
$bdde:
	$c0.x += ($7e + $7e);
	return;
}
```


