
# $31:b9ab segmentate



>分裂


### args:
+ [in] u8 $18 : enemyIdOfSegmentating
+ [in] u8 $1c : enemyIdOfTargetSpace
+ [out] ptr $20 : pNewlyGeneratedEnemy

### (pseudo-)code:
```js
{
	$1e,1f = #7675 + mul_8x8(a = $18,x = #40);	//fcd6
	$20,21 = #7675 + mul_8x8(a = $1c,x = #40);
	for (y = #3f;y > 0;y--) {	
		$20[y] = $1e[y];
	}
$b9dc:
	$20[y = #2c] = $1c | #80 & #e7; y += 2;
	$20[y] = 0;
	return;
$b9ed:
}
```



