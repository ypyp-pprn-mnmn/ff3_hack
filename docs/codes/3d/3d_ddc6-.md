
# $3d:ddc6


## code:
```js
{
	call_switch2Banks(per8k:a = #0a); //ff03
	$80,81 = #8c00;
	loadPatternToVramEx(vramHigh:a = #00,per100hlen:x = #08); //de0f
	if ( ($6011 < 0)  //bpl ddf6
		&& ($78 == #03)) //bne ddf6
	{
		call_switch1stBank(per8k:a = #3a); //ff06
		clc;
		$3a:8518();
		call_switch2Banks(per8k:a = #3c); //ff03
		return $3c:94ff();
	}
$ddf6:
	$80,81 = #9400 + (($78 & #06) << 10);
	loadPatternToVram(per100hlen:x = #08); //de1a
	call_switch1stBank(per8k:a = #3a);
	clc;
	return $3a:8518();
}
```




