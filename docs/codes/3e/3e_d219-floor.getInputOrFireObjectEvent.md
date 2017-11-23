
# $3e:d219 floor::getInputOrFireObjectEvent


## args:
+	[in] ptr $72 : object event param ptr
## code:
```js
{
	if ($6c == 0) return field::getAndMaskInput(); //$d27a;
	if ($17 != 0) { //beq d226
		$17--;
		//return $d26d();
	} else {
$d226:
		call_switch1st2Banks(per8kbase:a=#2c); //ff03
		if ($72[y = 0] == #fe) { //bne d24c
			$17 = $72[++y];
			$17--;
			$72,73 += #0002;
			return call_switch1st2banks(per8kbase:a=#3c);
		}
$d24c:
		$70 = a;
		$71 = $72[++y];
		x = 1;
		if ( ((a = $70) >= #e4) //bcc d261
			&& (a < #fd) ) //bcs d261
		{
			x = 2;
		}
$d261:
		$72,73 += x;
	}
$d26d:
	call_switch2ndBank(per8k:a = #3b); //ff09
	floor::call_dispatchObjectEvent(); //$3b:a000();
	return call_switch1st2Banks(per8kbase:a = #3c); //ff03
}
```




