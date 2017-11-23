
# $31:a65e useItem



>dispid:04 [battleFunction04]


### (pseudo-)code:
```js
{
	$78d5 = #1;
	$7ec2 = #14;
	$72 = 1;
	a =$78d7 = $1a;	//actionId(=itemId)
	if (a < #98) { //bcs a69d
		//装備を使った
		mul8x8(a,x = #8)
		$1a,1b += #9400;
		a = $1a[y = #4] & #7f;
		if (a == #7f) { //bne a694
$a691:
			goto $a722;
		}
$a694:
		$1a = a & #7f;
		a = #1;
		//jmp a71b
	} else if (a < #c8) { //bcs a691
$a69d:
$a6a1:
		$46,47 = (a - #98) + #91a0;
		$4a = #18
		$4b = #01
		a = #17
		copyTo7400();	//fddc
$a6bc:
		a = $1b = $7400;
		if (a != #7f) { //beq a722
$a6c5:
			//if (($7ed8 & #10) != 0) { //beq a6d2
			//	if ($1a == #ad) goto a722; //beq a722
			//}
			if (($7ed8 & #10) == 0) || ($1a != #ad)) {
$a6d2:
				x = 0;
				while ($60c0.x != $1a) { x += 2;}
$a6df:
				x++;
				$60c0.x--;
				if ($60c0.x == 0) {
					x--;
					$60c0.x = 0;
				}
$a6ee:
				$1a = $1b;
				if ($78d7 < #a6) {//bcs $a6fd
					//a6:ポーション より前(イベントアイテム)
					a = 0; goto $a71b;	//beq
				}
$a6fd:
				$46,47 = #a35e + (a - #a6);
				$4a = #18;
				a = x = 0;
				$4b = ++x;
				copyTo7400();	//fddc
$a718:
				a = $7400;
			}
		}
	}
$a71b:
	$7c = $30 = a;
	//$1a = actionId
	return doSpecialAction();	//$af77();
$a722:
	$78d5 = 1;
	$7ec2 = #18;
	$78da = #51;	//"なにも おこらなかった"
	return;
}
```




