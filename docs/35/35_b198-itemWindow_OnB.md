
# $35:b198 itemWindow_OnB

<summary></summary>

## args:
+ [in,out] u8 $67 : mode (0 = 1st,1=2nd selection)
## (pseudo-)code:
```js
{
	if (0 != (a = $67)) {
		$67--;
		tileSprites2x2(index:$1a = 1, top:$1c = #f0, right:$1d = #f0);	//$34:892e()
		backToItemWindowInputLoop();	//jmp $aeaa
	}
$b1ae:
	$52--;	//current char index?
	return endItemWindow();	//here $b1b0
$b1b0:
}
```



