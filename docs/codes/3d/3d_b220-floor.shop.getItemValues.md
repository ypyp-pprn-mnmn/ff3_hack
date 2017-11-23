
# $3d:b220 floor::shop::getItemValues


### (pseudo)code:
```js
{
	for (x = 7;x >= 0;x--) {
$b222:
		$7b80.x = $7b01.x;
	}
	for (y = 0;y < 8;y++) {
$b22d:
		floor::getTreasureGil( treasureParam:x = $7b80.y ); //$f5d4
		$7ba8.y = $80;
		$7bb0.y = $81;
		$7bb8.y = $82;
	}
$b247:
	return;
}
```



