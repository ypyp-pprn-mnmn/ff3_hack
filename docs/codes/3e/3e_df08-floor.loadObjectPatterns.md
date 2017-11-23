
# $3e:df08 floor::loadObjectPatterns


### args:
+	[in] u8 $78 : world

### code:
```js
{
	$8c,8d = #9400 + ($78 >= 2 ? #100 : 0);
	$8a = $8b = 0;
$df1a:
	do {
		floor::loadObjectPattern();	//$df41
		$8b += #10;
	} while (++$8a < #0c); //bcc df1a
$df2c:
	call_switch1stBank(per8k:a = #0d); //ff06
	$80,81 = #9400;
	reurn loadPatternToVramEx(ptr:$80, vramHigh:a = #1e, lenHigh:x = #02); 
}
```




