
# $31:a2e9 getRandomTargetFromEnemyParty

<summary></summary>

## notes:
//battleFunction06
## args:
+ [in] BattleChar *$5b : player party base
+ [in] u8 $5f : player offset (in bytes)
+ [out] BattleChar *$6e : current player
+ [out] BattleChar *$70 : randomly selected target
## (pseudo-)code:
```js
{
	$22,23 = #7675;
	$6e,6f = $5b,5c + $5f;
	a = #7;
	//fall through
}
```


**fall through**

