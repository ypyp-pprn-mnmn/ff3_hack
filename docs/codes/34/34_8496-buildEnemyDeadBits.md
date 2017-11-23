
# $34:8496 buildEnemyDeadBits

<summary></summary>

## args:
+ [in] u8 $7da7[8] : indexToGroup
+ [in] u8 $7ec4[8] : enemyStatus
## (pseudo-)code:
```js
{
	for (x = 0;x != 8; x++) {
$8498:
		if ( $7ec4.x >= 0) { //bmi $84b2
			if ($7da7.x == #ff) { //bne $84b9
				$84c7();
				$7e ^= #ff;
				call_2e_9d53(a = #0b);
			}
		} else {
$84b2:
			if ($7da7.x != #ff) goto $84bf //bne $84bf
		}
$84b9:
	}
	return;

$84bf:
	$84c7();
	call_2e_9d53(a = #0a);
$84c7:
	$7e = x = 0;
	for (x;x != 8;x++) {
$84cb:
		a = $7ec4.x;
		a <<= 1; rol $7e;
	}
	return;
$84d7:
}
```



