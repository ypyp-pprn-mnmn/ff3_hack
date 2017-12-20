
# $34:81a0 battle.init_players_defence_powers
> プレイヤー側キャラクター4名の物理防御力(offset 0x23)を、防御フラグ($7ce4)に基づいて設定する。

### args:
+	in u8 $7ce4[4]: defence flags.
+	in BattleCharacter* $5b: pointer to player-side characters
+	out u8 $52: 0 as a player index

### callers:
+	$34:8074 battleLoop

### local variables:
+	u8 $52: player index

### notes:
if a player had been in 'defending' state (i.e, the flag is set), the defence power of that player set to 0.
it is unsure whether correct or not, impact of this to be confirmed.

### (pseudo)code:
```js
{
	//write code here
}
```

