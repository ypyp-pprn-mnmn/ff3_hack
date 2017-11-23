
# $3f:f5c4 getTreasureItemId //getTreasureParam


### args:
+	[in] x : treasureId
+	[out] a : itemId
+	$01:9c00 u8 param[0x200]

### code:
```js
{
	call_switch1stBank(per8k:a = #01); //ff06
	a = $9c00.x;
	if ((y = $78) != 0) {
		a = $9d00.x;
	}
$f5d3:
	return;	
}
```




