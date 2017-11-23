
# $35:a848 commandWindow_selectSingleTargetAndGoNext



### (pseudo-)code:
```js
{
	$54 = a;
	$b3 = 0;	//単数選択
	call_2e_9d53(a = #10);	//$3f:fa0e(); 対象選択
	setYtoOffset2F();	//$9b94
	if (0 != (a = $b4) ) {
$a85d:	
		$5b[y] = a;	//2f:target bits
		$5b[++y] = $b5; y-=2;	//30:target flag
		$5b[y] = a = $54	//2e:actionid
		$52++;
	}
$a86c:
	pop a;
	pop a;
	$54 = 0;
	return getCommandInput_next(preventRedraw:a = 1);	//jmp 99fd
}
```



