
# $34:8306 updatePlayerBaseParams

<summary></summary>

## (pseudo-)code:
```js
{
	for ($52 = 0;$52 != 4;$52++) {
$830a:
		$8026();
	}
$8315:
	for ($0052 = 0;$52 != 4;$52++) {
$831a:
		y = updatePlayerOffset();	//a541
		$18 = $5b[++y] & #fe;
		setYtoOffset03();	//$9b8d();
		//hp
		$19,1a = $5b[y,++y];
		x = 0;
		setYtoOffsetOf(a = #7);	//$9b88
		for (x;x != 8;x++) {
$8338:
			$1b.x = $5b[y++];	//mp
		}
$8342:
		setYtoOffsetOf(a = #2);
		$57[y] = $18;	//status
		setYtoOffsetOf(a = #c);
		$57[y] = $19;	//hp
		$57[++y] = $1a;
		
		x = 0;
		setYtoOffsetOf(a = #30);
		for (x;x != 8;x++) {
$8360:
			$57[y] = $1b.x;	//mp
			y += 2;
		}
$836b:
	}
$8373:
	return;
}
```



