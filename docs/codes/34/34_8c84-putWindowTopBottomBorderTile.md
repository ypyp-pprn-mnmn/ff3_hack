
# $34:8c84 putWindowTopBottomBorderTile

<summary></summary>

## args:
+ [in] u8 $1a : behavior [xxxxxxba] (a:put left-corner b:put right-corner)
+ [in,out] u8 $1e : vertical-side (1:top 0:bottom) ; toggled on each call
+ [in,out] u16 $2a : vramAddr
+ [in,out] u16 $2c : vramAddrForExtra
+ [in] u8 $78b8 : width (without border)
+ [in] u8 $78b9 : extraWidth
## (pseudo-)code:
```js
{
	$1d = #f7;	//border-topleft 
	$1e = a = $1e ^ 1;
	a <<= 2;	//$fd40
	$1d += ($1e + a);	//0 or 5
	presentCharacter();	//$34:8185();
	setVramAddr(high:a = $2b,low:x = $2a);	//$3f:f8e0
	setBackgroundProperty();	//$34:8d03();
	x = $1d;
	a = $1a >> 1;
	if (!carry) x++; //bcs$8cad
$8cad:	
	$2007 = x;	
	$1d++;
	for (x = $78b8;x != 0;x--) {	//if (x == 0) $8cbf;
$8cb9:		$2007 = $1d;
	}
$8cbf:
	x = $78b9;
	if (x != 0) {	//beq $8cd9
		$2006 = $2d; $2006 = $2c;
		setBackgroundProperty();	//$34:8d03();
		for (x;x != 0;x--) {
$8cd3:
			$2007 = $1d;
		}
	}
$8cd9:
	a = $1a >> 2;
	if (carry) $1d++; //bcc $8ce1
$8ce1:	
	$2007 = $1d;
	$2a,2b += #0020;
	$2c,2d += #0020;
	return setBackgroundProperty();	//jmp $34:8d03
$8d03:
}
```



