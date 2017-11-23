
# $31:b752 doMagicHaste



### (pseudo-)code:
```js
{
	if ($70[y = #19] != #ff) //beq b7c1
		&& ($79[y = #1e] != #ff) //beq b7c1
		&& ($70[y = #10] < #10) //bcs b7c1
		&& ($70[y = #1c] < #10) //bcs b7c1
	{
$b772:
		u16 temp = $70[y = #19] + $78,79;
		$70[y = #19] = (u8) temp;
		if (temp >= 0x100) { //beq b789
			$70[y = #19] = #ff;
		}
$b789:
		//y = #1eについてb772-と同じ
$b7a0:
		$70[y = #17] = max(16, $70[y = #17] + $7c);
$b7af:
		$70[y = #1c] = max(16, $70[y = #1c] + $7c);
		return setResultDamageInvalid(); //b74b
	} else {
$b7c1:
		setResultDamageInvalid();
		return clearEffectTarget();
	}
}
```



