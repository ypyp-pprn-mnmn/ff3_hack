
# $31:a300 getRandomTarget



### args:
+ [in] a : maximum index (inclusive)
+ [in] ptr $22 : pTargetSideBase (= $7575 or $7675)
+ [in] BattleChar* $6e : actor
+ [out] $69 : failed (01=failed)
+ [out] BattleChar* $70 : selected target

### (pseudo-)code:
```js
{
	$4a = a;
	push (a = $1a);
	for ( a = 0,x = 4; x > 0;x--) {
$a309:
		$65.x = a;
	}
$a30e:
	do {
		$30 = getBattleRandom(a = $4a);	//$beb4();
		mul_8x8(a, x = #$40);	// $fcd6();
		$70,71 = $1a,1b + $22,23;
$a327:
		if ( 0 == ($70[y = #1] & #c0)  //bne a336
			&& 0 == ($70[++y] & 1) ) //beq a34e
		{
$a34e:
			$78d8 = getIndexAndMode(ptr : $70) & #87;//$bc25()
			flagTargetBit(a = 0, x = $30); //fd20
			$7e99 = $6e[y = #2f] = a;
			goto $a364;
		}
$a336:
		//target is ( dead | stone | jumping)
		$65.(x = $30) = 1;
	} while ( $65+$66+$67+$68 != 4 );
	$69++;
$a364:
	$1a = pop a;
	return;
$a368:
}
```




