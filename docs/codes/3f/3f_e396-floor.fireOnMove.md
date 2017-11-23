
# $3f:e396 floor::fireOnMove


## args:
+	[out] bool carry : ?
## code:
```js
{
	floor::getEventSourceCoodinates(); //$e4e9();
	$e3f1();	//handle move/collision?
	if (!carry) { //bcs $e3e5
$e39e:
		floor::getChipEvent();	//$e51c();
		//$44 = 80:event? 40:encountable?
		if ($44 >= 0) { //bmi $e3d0;
			if (($44 & #40) != 0) { //bvc e3b4
$e3a9:
				call_switch2ndBank(per8k:a = #3d);
				sec;
				$3d:bc5b();	//checkEncounter
				a = $44;
			}
$e3b4:
			a &= 7;
			if (a != 0) { //beq e3ca
				if (a < 4) { //bcs e3c8
					if (a == 3) $e3e5; //beq
					a |= $a5;
					if (a == 3) $e3e5; //beq
					$a5 = a;
				}
				clc;
				return;
			}
$e3ca:
			$a5 = 0;
			clc;
			return;
		}
$e3d0:	//event
		x = ($45 >> 4) << 1;	//note: not >>3 (always lsb = 0)
		$80,81 = $e669.x,$e66a.x;	//3f:e669 (7e669)
	//e669:
	//	89 E6  8F E6  B9 E6  B9 E6
	//	95 E6  9B E6  A8 E6  B9 E6
	//	B9 E6  B9 E6  B9 E6  B9 E6
	//	B3 E6  B3 E6  B3 E6  BE E6
		return (*$80)();
	}
$e3e5:
	$45 = $ab = 0;
	$44 = $43;
	sec;
	return;
}
```




