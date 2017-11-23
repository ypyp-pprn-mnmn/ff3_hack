
# $31:b480 handleHaste



>specialHandler09: ヘイスト


### (pseudo-)code:
```js
{
	clearEffectTargetIfMiss(); //b921
	if (!equal) { //beq b48b
		calcHealAmount();	//$b6dd();
		$b752();
	}
$b48b:
	return;
}
```



