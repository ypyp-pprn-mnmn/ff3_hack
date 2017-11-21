
# $35:b1b0 endItemWindow

<summary></summary>

## (pseudo-)code:
```js
{
	eraseWindow();	//$34:8eb0();
	$10 = 0;
	$08 &= #fe;
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5();
	init4SpritesAt$0220(index:$18 = 0);	//$34:8adf();
	init4SpritesAt$0220(index:$18 = 1);	//$34:8adf();
$b1ce:	$52++;
	//無条件にこれを実行するのがウインドウイレースの原因
$b1d0:	dispatchBattleFunction(5); //$34:8026();	
	a = 0;
$b1d5:	returnToGetCommandInput();//jmp $34:99fd
$b1d8:
}
```



