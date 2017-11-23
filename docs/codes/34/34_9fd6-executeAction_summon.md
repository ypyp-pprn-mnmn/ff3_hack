
# $34:9fd6 executeAction_summon



### (pseudo-)code:
```js
{
	$7e93 = 0;
	for (x = #3f;x >= 0;x--) {
		 $7875.x = 0;
	}
	$30 = 2;
	$52 = getActor2C() & 7;	//$a42e();
	y = updatePlayerOffset();	//$a541
	if ( $57[y] != #13
		&& $57[y] != #14)
	{
$9ffc:
		a = getSys1Random(max:a = #63);	//$a564;
		if (a < 50) {
			$30--;
		}
		$30--;
	}
$a009:
	x = $52;
	a = $1a = $7ac7.x & 7;
	a <<= 4;	//$fd3e
	$7e94 = a | $30;
	$6e,6f = #7875;
	setYtoOffsetOf(a = #0f);	//$9b88
$a027:
	for (x = 2;x >= 0;x--) {
		$18.x = $5b[y] << 1; y++;	//熟練 知性 精神
	}
$a032:
	setYtoOffsetOf(a = #1);
	$6e[y = 1] = $5b[y] & #30;	//

	for (x = 2,y = #f; x >= 0;x--,y++) {
		$6e[y] = $18.x;
	}
$a04b:
	$6e[y = 0] = $1a;	//lv = 熟練 << 1
	$6e[y = 3] = 3;	//hp
	
	x = $7ac2
	$7acb.x = #88;

	$6e[y] = getActor2C() | #90;
$a065:
	x = $52;
	a = $18 = $7ac7.x & 7

	push (a = ((a << 1) + $18) + $30 );
	$26 = $18 = a + #$5b
	loadTo7400FromBank30(index:$18, size:$1a = 8, base:$20 = #98c0, dest:x = 0);	//$ba3a
$a08c:
	if ($7405 < 0) { //bpl a09b
		$27 = #f0;
		$28 = #40;
		//bne a0da
	} else {
$a09b:
		if (($7405 & #40) != 0) { //beq a0ac
			$28 = #c0;
			$27 = #ff;
			// bne a0da
		} else {
$a0ac:
			do {
				$27 = getSys1Random(max:a = #7);	//$a564
				x = $40;
				mul8x8(a,x);	//$fcd6
				$1a,1b += #7675;
			} while ( ( $1a[y = 1] & #e0 ) != 0);
$a0cd:
			$27 = flagTargetBit(a = 0,target:x = $27);	//$fd20
			$28 = #80;
		}
	}
$a0da:
	$6e[y = #2e] = $26;	//2e:actionId
	$6e[++y] = $27;		//2f:targetBit
	$6e[++y] = $28;		//30:targetFlag
$a0ea:
	$5d,5e = #7675;
	pop a; push a;
	//a = (a << 1) + $7ac7.(x = $52) & 7 + $30;
	$78da = a + #78;
	$78d9 = pop a + #21;
	return $9de4;
$a104:
}
```



