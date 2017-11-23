
# $31:bf53 checkSegmentation	



>分裂判定


### args:
+ [in] u8 $7da7 : indexToIdMap
+ [out] u8 $7ee1 : segmenated enemy's id

### notes:
>使用技リストの1個目が#$4fの敵に
>暗黒属性以外の攻撃が1回以上命中した場合
>分裂処理を行う
>なお二刀流の場合は命中した手がどちらかによらず両手が暗黒でないと分裂する

### (pseudo-)code:
```js
{
	$18 = 0;
	if ( (getTarget2C() < 0) //bpl bfbc
		&& ( ($e0.(x = $64) & #e8) == 0) //bne bfbc
		&& ( ($e0.(++x) & #e0) == 0) ) //bne bfbc
		&& ( $70[y = #38] == #4f) //bne bfbc
		&& ( $bb|$bc != 0) //beq bfbc
		)
	{
$bf7b:
		if (($6e[y = #31] > 0) { //beq/bmi bf9d
			if (($6e[y = #16] & 2) == 0) $bfae; //beq
$bf8b:
			if ($6e[y = #32] <= 0) goto $bfbc; //beq/bmi bfbc
$bf93:
			if (($6e[y = #1b] & 2) == 0) $bfae:
			goto $bfbc;	//bne
		} else {
$bf9d:		
			if ($6e[++y] > 0) { //beq/bmi bfae
$bfa4:
				if (($6e[y = #1b] & 2) != 0) goto $bfbc; //bne
			}
		}
$bfae:
		for (x = 0;x != 6;x++) {
$bfb0:
			if ($7da7.x == #ff) goto $bfbd;
		}
	}
$bfbc:
	return;
$bfbd:
	$1c = x;
	$7ec4.x = 0;
	x <<= 1;
	$e0.x = 0;
	x = $68;
	a = $7be1;
	$7be1 = andNotBitX();	//$fd2c();
	x = $18 = getTarget2C() & 7;	//bc25
	$7ee1 = $7da7.x;
	segmentate();	//$b9ab();
$bfe8:
	a = y = 0;
	$20[++y] = a;	//status0
	$20[++y] = a;	//status1
	$78da.(x = $78ee) = #6f; //"ぶんれつした!"
	return;
$bffa:
}
```



