
# $34:8012 dispatchBattleFunction

<summary></summary>

## (pseudo-)code:
```js
{
	a = 0; goto $8038; //ex.ほのお
$8016:	a = 1; goto $8038;
$801a:	a = 2; goto $8038; //decide enemy action
$801e:	a = 3; goto $8038; //たたかう
$8022:	a = 4; goto $8038;
$8026:	a = 5; goto $8038; //on cancel item window
$802a:	a = 6; goto $8038;
$802e:	a = 7; goto $8038;
$8032:	a = 8; goto $8038;
$8036:	a = 9; goto $8038;
$8038:
	$4c = a;
	call_bank30_9e58(); //$3f:fdf3();
}
```



