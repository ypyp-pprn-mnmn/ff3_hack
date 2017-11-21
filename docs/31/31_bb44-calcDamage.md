
# $31:bb44 calcDamage

<summary></summary>

## notes:
$1c,1d = ((($25*(1.0~1.5)*($27/2)+$28*$29)-$26)*$7c)/$2a
## args:
+	[in] u16 $25,2b : attack power?
+	[in] u8 $26 : defence power?
+	[in] u8 $27 : attr multiplier
+	[in] u8 $28 : additional damage (critical modifier)
+	[in] u8 $29 : critical count(0/1)
+	[in] u8 $2a : damage divider (target count)
+	[in] u8 $007c : damage multiplier (hit count)
+	[out] u16 $1c : final damage (0-9999)
## (pseudo-)code:
```js
{
	a = $25,2b >>= 1;	//hibyte:2b
	getRandom(a);	//$31:beb4();
	$18,19 = (a + $25,$2b);
	$1b = 0;
	a = $27;
	a >>= 1;
	if (0 == a) {
		$18,19 >>= 1;
		$1c,1d = $18,19;
	} else {
$bb70:
		$1a = a;
		mul16x16();	//$3f:fcf5
	}
$bb75:
	$30,31 = $1c,1d
	x = $28; a = $29;
	mul8x8(a,x);	//$3f:fcd6
	$18,19 = ($30,31) + ($1a,1b);
$bb91:	a = get$6E_2C(); //$30:a2b5();
	//if (a >= 0) {
	//	a = $70[y]; //y=#2c
	//} else {
	if (a < 0 || $70[y] < 0) { //攻撃側か防御側どちらかは敵
$bb9a:
		$18,19 -= $26,#00;
		if ($18,19 < 0) { $18,19 = 0; }
	}
$bbaf:
	$1a,1b = $007c,#00;
	mul16x16();
	$18,19 = $1c,1d;
	$1a,1b = $2a,#00;
	div16();	//$3f:fc92
	if ($1c,1d > #270f) { $1c,1d = #270f; }
}
```



