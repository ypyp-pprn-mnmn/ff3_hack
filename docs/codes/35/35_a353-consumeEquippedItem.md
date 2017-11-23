
# $35:a353 consumeEquippedItem



### args:
+ [in] u8 A : hand (right=4, left=6)
+ [in] ptr $59 : equips
+ [out] u8 $24 : recalcRequired (consumed item count reached 0)

### (pseudo-)code:
```js
{
	setYtoOffsetOf(a);	//$9b88();
	
	if (--$59[y] == 0) {
		$59[--y] = 0;
		$24++;
	}
	return;
$a367:
}
```



