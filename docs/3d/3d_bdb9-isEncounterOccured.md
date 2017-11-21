
# $3d:bdb9 isEncounterOccured


## args:
+	[in] u8 $48 : warpId
+	[in] u8 $f8 : bound
## (pseudo)code:
```js
{
	if ($6c != 0) bdb8;
	field::getRandom();	//$c711();
	if (a >= $f8) bdb8;
$bdc4:
	call_switch1stBank(per8k:#2e); //ff06
	x = $48;
	if ($78 == 0) { //bne bdda
		a = $92f0.x;
$bdd2:
		getEncounterId();	//$bd4d();
		$ab = #20;
		return;
	}
$bdda:
	a = $93f0.x;
	goto $bdd2;
}
```

