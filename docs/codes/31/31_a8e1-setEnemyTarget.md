
# $31:a8e1 setEnemyTarget

<summary></summary>

## args:
+ [in] x : index of target
+ [in] BattleChar* $24
## (pseudo-)code:
```js
{
	x = a;
	a = 0;
	flagTargetBit(a,x);	//$fd20
	$24[y = #2f] = a;
	return;
}
```



