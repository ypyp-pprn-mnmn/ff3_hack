
# $31:b15f invokeActionHandler



### args:
+	[in] u8 $7404 : handlerType (from actionParam[4])
	-	分裂=11

### (pseudo-)code:
```js
{
	$18,19 = ($7404 << 1) + #ba9c;
	$1a,1b = *($18,$19)
	(*$1a)();	//funcptr
$b17c:
}
```



