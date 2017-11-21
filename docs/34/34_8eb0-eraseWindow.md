
# $34:8eb0 eraseWindow

<summary></summary>

## (pseudo-)code:
```js
{
	$18 = #2380;
	$1a = #2780;
	y = #a;
	for (y = 10;y != 0;y--) {//下から1行ずつ消していく
$8ec2:
		presentCharacter();	//$34:8185();
		a = $19; x = $18;
		setVramAddr();	//$3f:f8e0();
		setBackgroundProperty();$34:8d03
		a = 0;
		for (x = 0x20;x != 0;x--) {
			$2007 = a;	//write to vram
		}
$8eed:
		$18,19 -= #0020;
		$1a,1b -= #0020;
	}
$8f0a:	return;
}
```



