
# $34:94d6 dispCommand_00010204_closeWindow



>現在のコマンド番号に対応するウインドウを消す


### args:
+ [in] u8 $78d6[] : dispCommandParams
+ [in] u8 $4b : currentDispCommand

### notes:
コマンド番号:
+ 00:行動者
+ 01:行動名
+ 02:効果対象
+ 03:追加効果 
+ 04:メッセージ

### (pseudo-)code:
```js
{
	x = $4b;
	a = $78d6.x;
	if (a == #ff) return;	//beq $94e4
	$34:8e14(a = $4b);	//
$94e4:
	return;	//jmp $9051
}
```



