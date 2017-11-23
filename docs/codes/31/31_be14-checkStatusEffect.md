
# $31:be14 checkStatusEffect



### args:
+ [in] u8 $742c : physical evade
+ [in] u8 $742e : status resist
+ [in] u8 $7442 : hit
+ [in] u8 $7444 : status to apply
+ [in] u8 $7c : hit count

### (pseudo-)code:
```js
{
	$25 = $7444;	//=$6e[#1a]
	if ($25 == 0) return;
	
	$24 = $7c;
	if ($24 == 0) return;

	a = $742e & $25;
	if (a != 0) return; //resisted

	a = $7442 - $742c;
	if (a < 0) { a = 0;}
$be33:
	$25 = a;
	getNumberOfRandomSuccess($24,$25);//$bb28()
	if (0 != a) {
		$24 = $7444;
		applyStatus();	//$31:bbf3();
	}
}
```



