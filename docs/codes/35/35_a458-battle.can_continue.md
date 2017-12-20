
# $35:a458 battle.can_continue
> 敵味方の状況をチェックして、戦闘継続可能かどうかを判定する。

### args:
+ in,out u8 $78d3: continuity flags.
	+ 0x80: all of player side can't continue
	+ 0x40: all of enemy side can't continue ($7dd2 == 0)
	+ 0x02: player party is about to escape
+ in u8 $7dd2: # of enemies alive
+ in BattleCharacter* $5b: pointer to characters in player party

### local variables:
+	u8 $52: player index

### notes:
former name: canPlayerPartyContinueFighting

### (pseudo-)code:
```js
{
	a = $78d3 & 2
	if (a == 0) { //beq a486
		$52 = 0;
		for ($52 = 0;$52 != 4;$52++) {
a463:
			updatePlayerOffset();	//$a541();
			y = a + 1;
			a = $5b[y] & #c0;	//dead | stone
			if (a == 0) goto $a47c;
		}
a478:	a = #80;
		bne $a483;
a47c:
		if ($7dd2 != 0) return;	//$a486
		a = #40;
a483:
		$78d3 = a;
	}	
a486:
	return;
}
```






