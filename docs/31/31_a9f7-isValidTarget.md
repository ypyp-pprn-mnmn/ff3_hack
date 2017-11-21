
# $31:a9f7 isValidTarget

<summary></summary>

## args:
+ [in] u8 a : targetIndex
+ [out] bool zero : (1:valid, 0:invalid(dead|stone|jumping) )
## (pseudo-)code:
```js
{
	$18 = a;
	calcDataAddress(index:$18, size:$1a = #40, base:$20 = #7575);	//$be9d();
	if (($1c[y = 1] & #c0) == 0) { //bne aa15
		a = $1c[++y] & 1;
	}
$aa15:
	return;
$aa16:
}
```



