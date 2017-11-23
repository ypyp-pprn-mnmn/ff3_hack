
# $2f:a1b9 loadSprites?

### args:
+	[in] u8 a : loadParamIndex
+	[in] ptr $7e : 

### code:
```js
{
	mul_8x8reg(a, x = 6);	//$f8ea
	$18,19 = #a15f + (a,x);	//$a15f: LoadToVramParams
	push (a = y);
	$7e,7f += $18[y = 0,1];	//srcOffset	//r,l:$b000
	$80,81 = $18[y = 2,3];	//destVram	//r:$1490 l:$1510
	$82 = $18[++y];		//size		//r,l:$08
	$84 = $18[++y];		//srcBank	//r,l:$15
	copyToVramDirect();	//$f969();
	y = pop a;
	return;
}
```


