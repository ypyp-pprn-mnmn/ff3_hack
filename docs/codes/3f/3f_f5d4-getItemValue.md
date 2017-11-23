
# $3f:f5d4 getItemValue //getTreasureGil


### args:
+	[in] x : itemid
+	[out] u24 $80 : = $10:9e00[x]

### callers:
+	$3d:b230 @ floor::shop::getItemValues
+	$3d:b271 @ floor::shop::getItemValue
+	$3f:ef73 @ field::decodeString 
+	$3f:f5b8 @ floor::getTreasure

### notes:
caller expects y has been unchanged

### code:
```js
{
	call_switch1stBank(per8k:a = #10); //ff06
	x <<= 1;
	if (!carry) {
		$80 = $9e00.x;
		a = $9e01.x;
	} else {
		$80 = $9f00.x;
		a = $9f01.x;
	}
	$81 = a;
	$82 = 0;
	x >>= 1;
	return call_switch1stBank(per8k:a = #3c); //ff06
}
```



