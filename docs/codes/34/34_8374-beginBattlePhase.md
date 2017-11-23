
# $34:8374 beginBattlePhase



### (pseudo-)code:
```js
{
	$74 = 0;
	for ($52 = 0;$52 < 4;$52++) {
		a = updatePlayerOffset();	//$35:a541()
		y = a + #3f;
		if (0 != $5b[y] ) {
			$34:9ae7();
		}
$8388:
		setYtoOffset2E();	//$34:9b9b();
$838b:
		a = $5b[y];	//y=2e=commandId
		if (a == 6 || a == 7) {//"逃げる"か"とんずら"
$8395:
			$74++;
		}
$8397:
	}
	
}
```



