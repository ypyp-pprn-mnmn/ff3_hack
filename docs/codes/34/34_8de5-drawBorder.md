
# $34:8de5 drawBorder



### args:
+ [in] u8 $78b8 : midCharLength
+ [in] u8 $1a : leftMostChar
+ [in] u8 $1b : middleChar
+ [in] u8 $1d : rightMostChar
+ [in,out] u16 $60,61 : vramAddr (32bytes/row)

### (pseudo-)code:
```js
{
	presentCharacter();	//$34:8185();
	a = $61; x = $60;
	setVramAddr();	//3f:f8e0
	$2007 = $1a;
	for (x = $78b8,a = $1b;x != 0;x--) {
$8df9:		$2007 = a;
	}
$8dff:
	$2007 = $1d;
	$60,61 += #0020;
$8e11:	setBackgroundProperty();	//$34:8d03();
$8e14:
}
```



