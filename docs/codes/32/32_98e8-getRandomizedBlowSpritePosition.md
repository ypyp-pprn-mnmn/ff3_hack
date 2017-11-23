
# $32:98e8 getRandomizedBlowSpritePosition

### args:
+	[in] u8 $b6 : frameCount

### note:
偶数フレームしか座標を更新しないので
最初に表示するフレームが奇数フレーム(全体フレーム/2=奇数)だと
一発目のみその前に殴った敵の位置に表示される

### code:
```js
{
	if (($b6 & 1) == 0) { //b6=framecount bne 9912
$98ee:
		y = ($b8 & 7) << 1;
		$8c = $7dd7[y];	//enemy.x
		$8d = $7dd8[y];	//enemy.y

		getSys0Random_00_ff();	//$a44f();
		$be = (a & #1f) + $8c;
		
		getSys0Random_00_ff();	//$a44f();
		$bf = (a & #1f) + $8d;
	}
$9912:
	$8c,8d = $be,bf
	$8f = 0;
	return;
$991f:
}
```


