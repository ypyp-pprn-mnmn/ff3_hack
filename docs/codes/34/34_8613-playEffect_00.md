
# $34:8613 playEffect_00



>たたかう・うたう


### args:
+ [in] u8 $7e6f : targetside (0 = player)
+ [in] u8 $7e9a : effectSideFlags
+ [in] u8 $7e9b : targetBit
+ [in] u8 $bb,bc : hitCount

### (pseudo-)code:
```js
{
	$7e96 = x = 0;
	targetBitToCharIndex();	//$86ab();
	//if ((a = $7e9a) >= 0) $8647;
	if ($7e9a < 0) {
$8620:
		dispatchPresentScene_1f();	//$8545();
		//if ((a = $7e6f) == 0) $8637;
		if ($7e6f != 0) {
$8628:
			targetBitToCharIndex(x = 1);	//$86ab();
			$b8 = y;
			call_2e_9d53(a = #20);	//$fa0e
			return;	//jmp $8689
		}
$8637:
		targetBitToCharIndex(x = 1);	//$86ab();
		$0052 = y;
		call_2e_9d53(a = #14);
		return;	//jmp $8689
	} else {
$8647:
		$0052 = y;	//actor index
		//if ((a = $7e6f) == 0) $865e;
		if ($7e6f != 0) {
			targetBitToCharIndex(x = 1);	//$86ab();
			$b8 = y;
			call_2e_9d53(a = #12);
			return;	//jmp $8689
		}
$865e:
		$7e96++;
		push (a = $bb)
		push (a = $bc);
		$bb = $bc = 0;	//強制空振り
		call_2e_9d53(a = #12);
		x = 1;
		targetBitToCharIndex();	//$86ab();
		$0052 = y;
		$bc = pop a; //ヒット回数
		$bb = pop a;
		if ((a | $bc) != 0) { // beq 8689
$8684:
			call_2e_9d53(a = #14);
		}
	}
$8689:
	return;
$898a:
}
```



