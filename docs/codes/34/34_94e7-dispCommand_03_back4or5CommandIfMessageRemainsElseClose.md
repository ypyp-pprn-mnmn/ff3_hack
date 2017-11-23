
# $34:94e7 dispCommand_03_back4or5CommandIfMessageRemainsElseClose


キューにまだ表示すべきメッセージがあるなら
メッセージ表示コマンド(=09)の位置まで現在位置($64)を戻す
なければメッセージ用ウインドウ(左下の奴)を消す


### args:
+ [in] u8 $78d5 : commandChainId
+ [in] u8 $78da[] : dispCommandParams (for message window)
+ [in] u8 $78ee : current queue index

### notes:

### (pseudo-)code:
```js
{
	x = $78ee;
	a = $78da.x;
	if (a == #ff) jmp dispCommand_00010204();
$94f4:
	a = $78d5;
	if (a == 0) {
		$64 -= 4;
		return;
	}
$9503:
	$64 -= 5;
	return;	//jmp $9051
$950d:
}
```



