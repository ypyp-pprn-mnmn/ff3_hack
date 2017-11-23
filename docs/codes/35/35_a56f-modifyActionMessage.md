
# $35:a56f modifyActionMessage?

<summary></summary>

## args:
+ [in] u8 $7e88 : (invokedActionId)
+ [in] u8 $7e9b : effect target bits
+ [in] u8 $54 : (fight/special = 0)
+ [in] u8 $35:a5fd : hasActionMessage (bit array,higher bit = lower id)
## (pseudo-)code:
```js
{
	$24 = a = $7e88;
	if (0 != a && (a < #5b) ) {
		if (#44 != (a = $78da)) {	//#44:"ようすをみている" 
			if (0 == (a = $7e9b)) {	//
$a588:
				if (3 == (a = $54)) goto $a5dc;
$a58e:				a = #3b; x = $78ee;	//#3b:"こうかがなかった"
$a593:				$78da.x = a;
				if ($78ee == 0) goto $a5dc;
			}
$a598:			a = $54;
			if (a == 5 || a == 4) {
				$24 = (a == 5) ? 0x34 : 0x01;
				$54 = 0;
			}
$a5ae:			a = $78da(x = $78ee);
			if (0 == a) a = #ff; goto $a593;
$a5ba:			push (a = $24);
			a &= #f8;
			a >>= 3;	//$3f:fd46();
			x = a;
			y = a = (pop a) & 7; y++;
			a = $a5fd.x;	//flagBitsForAction (higher bit lower index)
$a5cb:			do {
				a <<= 1;
				y--;
			} while (y != 0);
$a5cf:
			if (carry) {
$a5d1:
				x = $78ee;
				$78da.x = $24 + #20;
			}
		} else {
			return; //a: $78da
		}
	}
$a5dc:
	x = $78ee; a = $54;
	if (a != 0) {
		switch (a) {
$a5ef:		case 1: a = #45;	//"アンデットにダメージ!"
$a5f3:		case 2: a = 1;		//"まほうをきゅうしゅうした!"
$a5eb:		default: a = #4f;	//"しっぱい!"
		}
$a5f5		$78da.x = a;
	}
$a5f8:
	$54 = a = 0;
$a5fc: 
	return;
$a5fd:	//flag bits table for action
}
```



