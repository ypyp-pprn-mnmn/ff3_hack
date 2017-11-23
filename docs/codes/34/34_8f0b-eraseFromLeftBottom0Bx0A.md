
# $34:8f0b eraseFromLeftBottom0Bx0A	//[eraseItemWindowColumn]

<summary></summary>

## (pseudo-)code:
```js
{
	$18,19 = #2380;
	for (x = #0a;x != 0;x--) {
$8f15:		presentCharacter();	//$34:8185
		bit $2002;
		$2006 = $19; $2006 = $18;	//vramAddr.high,vramAddr.low
		setBackgroundProperty();	//$34:8d03();
		for (a = 0,y = #b;y != 0;y--) {
$8f2c:			$2007 = a;
		}
		$18,19 -= #0020;
	}
$8f42:	return;
$8f43:
}
```



