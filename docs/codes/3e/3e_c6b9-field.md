
# $3e:c6b9 field


//	$44 < 0 && $45 >= 0
## args:
+	[in] u8 $42 : vehicle?
+	[in] u8 $78 : world
## code:
```js
{
	if ( ($78 != #04)  //beq c6cb
		&& $42 >= #04) //bcc c6cb
	{
$c6c5:
		//海中($78 == 4)でなく飛空艇に乗っている($42 >= 4)
		$44 &= #7f;	//イベント実行フラグクリア
	}
$c6cb:
	clc;
	return;
$c6cd:
}
```




