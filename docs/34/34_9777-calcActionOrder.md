
# $34:9777 calcActionOrder

<summary>行動順を決める</summary>

## args:
+ [out] u8 $7acb[#c+1] : ordered indices (#ff:last)
+ 	u8 $7400[2][#c] : weight values
## notes:
まず乱数を12個生成しその大きい順にindexを並び替える
次にプレイヤーキャラのagiを乱数により1~3倍し大きい順にindexを並び替える
12個の乱数値のうちindex9-12のある場所をプレイヤーキャラの大きかった順に埋めていく
## (pseudo-)code:
```js
{
	for (y = 0;y != #c;y++) {
$9779:
		getSys1Random(a = #ff);	//a564();
		$7400.y = a;
		$740c.y = y;
	}
$978a:
	getSortedIndices(base:$1a = #1, keys:$1c = #73ff,
		result:$1e = $740b, len:$22 = #c);	//$8f57();
	for (y = 0;y != #c;y++) {
$97a7:
		$7acb.y = $740c.y | #80;
	}
$97b4:
	for ($52 = 0;$52 != 4;$52++) {
$97b8:
		y = updatePlayerOffset() + #18;	//a541();
		$3c = a = $57[y];	//agi
		a = getSys1Random(a <<= 1) + $3c;
		$7400.(x = $52) = a;	//agi + (0 ~ agi*2)
	}
$97db:
	getSortedIndices(base:$1a = #1, keys:$1c = #73ff,
		result:$1e = #7403, len:$22 = #4);	//$8f57
$97f6:
	for (y = 0;y != 4;y++) {
$97f8:
		x = #ff;
		do {
$97fa:
			x++;
			a = $7acb.x;
		} while (a < #88);	
$9802:
		//#88: last index value of enemy party = (89,8a,8b,8c rolls placeholder)
		$7acb.x = $7404.y;
	}
$980d:
	for (x = #b; x >= 0;x--) {
		$7400.x = $7acb.x;
	}
	$24 = $25 = ++x;
	for ($25;$25 != #c;$25++) {
$981d:
		x = $25;
		if ($7400.x >= 0) { //bmi$9833;
			$52 = a;
			y = updatePlayerOffset();	//a541
			a = $5b[++y] & #c0;
			if (a != 0) continue;	//$985c;
			//else $984f
		} else {
$9833:
			a &= #7f;	//a: $7400.x
			mul_8x8(a,x = #40);	//fcd6
			$1a,1b += #7675;
			a = $1a[y = #1] & #e8;
			if (a != 0) continue;	//$985c;
		}
$984f:
		y = $24;
		x = $25;
		$7acb.y = $7400.x;
		$24 = ++y;
$985c:
	}
$9864:
	$7acb.(y = $24) = #ff;
	return;
$986c:
}
```



