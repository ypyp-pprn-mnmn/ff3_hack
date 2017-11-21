
# $31:b49b handleErase

<summary>specialHandler0B: イレース</summary>

## (pseudo-)code:
```js
{
	calcMagicHitCountAndClearTargetIfMiss();	//$b8e7();
	if (!equal) { //beq b4b8 //equal=miss
		if ( (getTarget2c() < 0) //bpl $b4b0
			&& ($7ed8 < 0) //bpl $b4b0
	{
		//対象が敵でかつボス戦
		clearEffectTarget();	//$b926();
		goto b4b8;
	} else {
$b4b0:
		$70[y = #20] &= #03;	//20:defAttr
	}
$b4b8:
	return;
}
```



