
# $3f:fbef getBattleRandom

<summary>指定した乱数系列から乱数値を一つ取得する</summary>

## args:
+	[in] u8 A : max?
+	[in] u8 X : min?
+	[in] u8 $21 : randSystemIndex?
+	[out] u8 A : rand  [x-a] の乱数値 上限も含む
## notes:
	上位8bitを$21で指定した系列から取得した乱数(0x00-0xFF),下位8bitを0x80とした16bit値(A)と最大と最小の差分(8bit)(B)を掛けて
	結果のbit16-23の8bitを乱数の基本値として採用する。
	結果のbit8-15=(diff*baseRand + diff>>1)が
	0x80以上で繰り上げ(小数部256/512以上で繰り上げ)
	=> (diff*(0x00~0xFF)/256 + diff/512) = diff*(1/512 ~ 511/512)
	繰上げの処理により最小値と最大値だけ出る確率が他の約半分
	(中央二人が狙われやすいのもそのせい?)

## code:
```js
{ 
	$20 = x;
	if (x == ff) {
		a = x;		
		return;
	} 
	if ( a == 0 || a == $20) return;
	
	a -= $20	//a:max - min
	$18 = a
	$1a = #80
	$19 = a << 1	//$18: diff
	x = $21
	a = $15,x; [$15,x]++
	x = a		//x:randIndex
	$1b = $7be3,x
	$1c = $18,19*$1a,1b //fcf5()
	x = $1e;	//(=diff * rand >> 8 & 0xFF)
	a = $1d		//(=diff * #80 >> 8 + diff * rand & 0xFF)
	if ($1d < 0) x++; //小数部+差分/2が0x80以上なら繰り上げる
	a = x;
	a += $20
}
```



