
# $34:8460 playEffect_0F

<summary></summary>

## args:
+ [in] u8 $7ee1 : segmentated enemy id (ff: none)
## (pseudo-)code:
```js
{
	showDamage();	//$34:868a();
	if ((a = $7ee1) >= 0) { //bmi 846f
		$7e = a;
		call_2e_9d53(a = #0c);	//fa0e
	}
$846f:	return;
}
```



