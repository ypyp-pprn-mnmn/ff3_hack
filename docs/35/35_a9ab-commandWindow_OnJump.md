
# $35:a9ab commandWindow_OnJump

<summary>08: ジャンプ</summary>

## (pseudo-)code:
```js
{
	$b3 = 0;	//single
	call_2e_9d53(a = #10);	//selectTarget
	setYtoOffset2F();	//9b94
	if ($b4 == 0) { //bne a9be
		clc bcc a9d3
	} else {
$a9be:
		if ($b5 >= 0) goto $a9ab; //bpl a9ab
$a9c2:
		$5b[y] = $b4;
		$5b[++y] = $b5;
		y -= 2;
		$5b[y] = #08;	//2e
		$52++;
	}
$a9d3:
	return getCommandInput_next(preventRedraw:a = 1);
$a9d8:
}
```



