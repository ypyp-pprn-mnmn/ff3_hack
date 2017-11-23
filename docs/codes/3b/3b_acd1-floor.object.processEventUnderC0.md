
# $3b:acd1 floor::object::processEventUnderC0


## args:
+	[in] u8 $70 : [iiiieeee] i:object index e:object event id
+	[out] u8 $17 :

## (pseudo)code:
```js
{
	a = $700c.(x = $70 & #f0);
	if (a != 0) {
$acce:
		$17++; return;
	}
$acdb:
	a = ($70 & #0f);
	if (a < 4) { //bcs acf7
		$84 = $7002.x;	//object.x
		$85 = $7003.x;	//object.y
		$86 = $7106.x;	//object2.layer
		a = $70;
		return $afdd();
	}
$acf7:
	if (a < 8) { //bcs ad0c
		y = (a & 3) << 1;
		$700e.x = $ad55.y;	//object.pBuilder
		$700f.x = $ad56.y;
		return;
	}
$ad0c:
	switch (a) {
	case 8: $7000.x = $700a.x; return;	//object.scriptId
	case 9: $7000.x = 0; return;
	case #0a: a = 1; return $ab71();
	case #0b: a = 0; return $ab71();
	case #0c: $7001.x |= #40;	//object.attr
	case #0d: $7001.x &= #b0;
	case #0e: return $ac68();
	default: return $ac25();
	}
}
```



