
# $30:9e58 invokeBattleFunction

<summary></summary>

## args:
+ [in] u8 $4c : functionId
## notes:
//	least value of S = $12 = $20 - ($0a + $06) (original:$14)
//		(dungeon_mainLoop - dungeon_mainLoop - beginBattle - call_doBattle - battleLoop)
//			+(presentBattle - pb_disorderedShot)
//			+(getPlayerCommandInput - commandWindow_OnItem)
//			+(executeAction>command_fight - doCounter - command_fight_doFight)
//
//	functionId : 
//		0 then doAction //ex.ほのお
//		3 then たたかう
//		5 then recalcBattleParams (OnCloseItemWindow etc)
//		7 then calcDataAddress($31:be9d) (OnExecuteAction)
## (pseudo-)code:
```js
{
	a = $4c << 1;
	$4c = #9e76 + a;
	$4c = *$4c;
	(*$4c)();	//funcptr
$9e76:
}
```





