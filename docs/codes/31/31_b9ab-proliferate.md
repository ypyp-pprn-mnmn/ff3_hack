
# $31:b9ab proliferate
>分裂 (former translation: 'segmentate')

### args:
+ [in] u8 $18 : enemyIdOfSegmentating
+ [in] u8 $1c : enemyIdOfTargetSpace
+ [out] ptr $20 : pNewlyGeneratedEnemy

### (pseudo-)code:
```js
{
	$1e,1f = 0x7675 + mul_8x8(a = $18,x = #40);	//fcd6
	$20,21 = 0x7675 + mul_8x8(a = $1c,x = #40);
	for (y = 0x3f;y > 0;y--) {	
		$20[y] = $1e[y];
	}
$b9dc:
	$20[y = 0x2c] = $1c | 0x80 & 0xe7; y += 2;
	$20[y] = 0;
	return;
$b9ed:
}
```


