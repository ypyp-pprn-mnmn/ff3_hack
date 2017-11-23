
# $34:9245 loadStatusMessage?



>load string using table $18:8c40


### (pseudo-)code:
```js
{
	setTableAddrTo$8c40();	//$34:95c6();
	x = $78ee;	
	loadString(index:a = $78da.x, dest:x = 0, base:$18);	// $35:a609();
$9253:
}
```



