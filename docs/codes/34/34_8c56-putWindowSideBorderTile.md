
# $34:8c56 putWindowSideBorderTile



### args:
+ [in,out] u8 $1b : side (1:left 0:right)  (toggled on each call)

### (pseudo-)code:
```js
{
	$1c = #fa;	//左枠線
	$1b = a = $1b ^ 1;
	$1c += a;	//#fa or #fb

	if (0 == (a = $1b)) { a = $1a >> 1; }
	else { a = $1a >> 2; }
	if (!carry) {
$8c77:
		$2007 = #ff;
	//bne $8c83
$8c7e:	} else {
		$2007 = $1c;
	}
$8c83:	return;	
	
}
```



