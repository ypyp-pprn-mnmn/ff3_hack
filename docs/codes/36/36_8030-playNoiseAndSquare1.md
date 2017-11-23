
# $36:8030 playNoiseAndSquare1


```js
{
	if ($7f49 == 0) return; //beq 80aa
	if ($7f4f >= 0) $8079 //bpl 8079
	if (($7f4f & 1) != 0) { //$8064 //beq
$803e:
		$7f4f &= #fe;
		$4004 = $7f8e|$7f80	//sq1 ctrl0
		$4005 = $7f87;		//sq1 ctrl1
		$4006 = $7f72;		//sq1 freq.low
		$4007 = $7f79;		//sq1 freq.high
		//goto $8079;
	} else {
$8064:
		$4004 = $7f8e | $7f80;
		a = $7f87 << 1;
		if (!carry) { //bcs 8079
			$4006 = $7f72;
		}
	}
$8079:
	if ($7f50 >= 0) return;	//bpl 80aa
	if (($7f50 & 1)) != 0) { //beq 809c
$8082:
		$7f50 &= #fe;
		$400c = $7f81 | #30;	//noise ctrl0; #30 = envelope decay loop | envelope decay disabled
		$400e = a = $7f73;	//noise freq.low
		$400f = a;		//noise freq.high
		return;
	}
$809c:
	$400c = $7f81 | #30;
	$400e = $7f73;
$80aa:
	return;
$80ab:
}
```



