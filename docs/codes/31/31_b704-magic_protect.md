
# $31:b704 magic_protect

<summary></summary>

## (pseudo-)code:
```js
{
	if ( ($70[y = #23] != #ff)  //bne b714
		|| ($70[y = #15] != #ff) //beq b745
	{
$b714:
		$70[y = #23] = max(255, $70[y = #23] + $78,79);
$b72b:
		$70[y = #15] = max(255, $70[y = #15] + $79,79);
$b742:
		return setResultDamageInvalid();
	}
$b745:
	setResultDamageInvalid();	//$b74b();
	return clearEffectTarget();	//$b926();
$b74b:
}
```



