
# $34:8160 endBattle



### (pseudo-)code:
```js
{
	prize(); //bb49
	updatePlayerBaseParams();	//$8306();
	if (($78ba & #08) != 0) {
		//backattack
		$88a4();
	}
$8170:
	dispatchBattleFunction08();	//$8032 [rebuildBackpackItems]
	if ( ($7ced == #79)  //bne 8184
		&& ($7cee != 0) //beq $8184
	{
	//79:くらやみのくも
		$78d3 = 0;
	}
$8184:
	return;
}
```



