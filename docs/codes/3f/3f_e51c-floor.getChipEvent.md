
# $3f:e51c floor::getChipEvent


## args:
+	[in] u8 $84,$85 : chip position(x,y)
+	[ou] y : chipId
+	[out] u8 $44 : chip attributes (80:event 40:encountable? 08:damage)
+	[out] u8 $45 : [hhhhiiii] h : eventId(index of handler), i: eventParam(serial number)
## code:
```js
{
	y = $4c;
	a = ($84 | $85) & #20;
	if (a == 0) { //bne e541
		//マップの範囲内
		$81 = #74 | (($85 & #1f) >> 3);
		$80 = ($85 << 5) | $84;
		y = $80[y = 0];	//y = chipID
	}
$e541:	
	$44 = $0400.y;
	$45 = $0500.y;
	return;
}
```





