
# $31:b474 handleProtect

<summary>specialHandler08: プロテス</summary>

## (pseudo-)code:
```js
{
	clearEffectTargetIfMiss(); //b921
	if (!equal) { //beq b47f
		calcHealAmount();	//$b6dd();
		$b704();
	}
$b47f:
	return;
}
```



