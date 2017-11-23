
# $33:adf4 damageToTilesAndColor

### code:
```js
{
	push (a = x);
	if ( $7e70 == #ff && $7e71 == #3f) { //bne bne $ae13
$ae04:
		$7e,7f,80,81,82 = 0;
		//goto aeab
	} else {
$ae13:
		if (($7e72 & #40) != 0) { //beq ae2f
$ae1a:
			$82 = 3;	//
			$7e = $81 = 0;
			$7f = $80 = #64;
			$80++;
			//goto aeab
		} else {
$ae2f:
			//inlined itoa_10000
$ae7a:
			if (($7e72 & #80) != 0) { //beq ae8c
$ae81:
				$18 = #66;
				$82 = #3;
				//jmp ae94
			} else {
$ae8c:
				$18 = #56;
				$82 = 3;
			}
$ae94:
			for (x = 0;x != 3;x++) {
$ae96:
				if ($7e.x != 0) break; //bne ae9f
			}
$ae9f:
			for (x;x != 4;x++) {
				$7e.x += $18;
			}
		}
	}
$aeab:
	x = pop a;
	return;
$aeae:
}
```


