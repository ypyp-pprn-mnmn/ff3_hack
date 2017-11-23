
# $2f:b15e presentScene_1d	

>[magic effect]


### args:
+	[in] u8 $7e9a :	side flag

### code:
```js
{
	a = $7e9a;
	if (a < 0) {
$b163:		dispatchEffectCommand(#d);	// $2f:af14();
	} else {
$b169:		moveCharacterForward();	//$2f:b38e();	//行動するキャラが前にでる
		$2f:a9cf();
		dispatchEffectCommand(#d);	//$2f:af14();
		$2f:b25b();
	}
$b175:
	a = 6;
	$2f:a1b3();
	$cc = 0;
}
```


