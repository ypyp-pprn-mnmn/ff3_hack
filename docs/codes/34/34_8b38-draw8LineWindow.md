
# $34:8b38 draw8LineWindow

<summary></summary>

## args:
+ [in] u8 $18 : left (border incl)
+ [in] u8 $19 : right (border incl)
+ [in] u8 $1a : behavior[xxxxxxba] (a:put left-border,b:put right-border)
+ [in] u16 $7ac0 : ptr to charTileArray ()
## (pseudo-)code:
```js
{
	push(a = $19);
	$1d = a & #7f;
	push(a = $18);
	$1c = a & #7f;
	$1e = pop a & #80;
	$1e ^= pop a & #80;	// (init$18 & #80 ^ init$19 & #80)
	if (a == 0) {	//bne $8b64;
$8b52:
		$78b8 = $1d - $1c - 1;//right - left - 1
		$78b9 = 0;
	} else {
$8b64:
		$78b8 = #1f - $1c;	//#1f - left
		$78b9 = $1d + #20 - $1c - 1 - $78b8;	//right+#20-left-1-width
	}
$8b7c:
	$2e,2f = $7ac0,7ac1;
	push (a = $18);
	a &= #80;
	if (0 == a) $2a,2b = pop a + #2260;
$8b9c:	else $2a,2b = #2660 + (pop a & #7f);
$8baa:
	a = $19 & #80;
	if (a == 0) $2c,2d = #2260;
$8bbb:	else $2c,2d = #2660;
$8bc3:
	$30 = 8;
	$1e = $1b = 1;
	putWindowTopBottomBorderTile();	//$34:8c84();
	for ($30;$30 != 0;$30--) {
$8bd0:
		presentCharacter();	//$34:8185();
		setVramAddr(high:a = $2b,low:x = $2a);	//$3f:f8e0
		putWindowSideBorderTile();	//$34:8c56();
$8bdd:
		y = 0; 
		for (x = $78b8;x != 0;x--) { //if (x == 0) $8bed;
$8be4:
			$2007 = $2e[y++];
		}
$8bed:
		x = $78b9;
		if (x == 0) { //$8bf8;	//bne
$8bf2:
			putWindowSideBorderTile();	//$34:8c56();
			//clc bcc 8c11
		} else {
$8bf8:
			$2006 = $2d;	//vram high
			$2006 = $2c;	//vram low
			setBackgroundProperty();	//$34:8d03();
			for (x; x != 0;x--) {
$8c05:
				$2007 = $2e[y++]
			}
			putWindowSideBorderTile();	//$34:8c56();
		}
$8c11:
		$2a,2b += #0020;
		$2c,2d += #0020;
		$2e,2f += $78b8;	//下位
		$2e,2f += $78b9;	//下位
		setBackgroundProperty();	//$34:8d03();
	}	//beq $8c53;
$8c53:
	return putWindowTopBottomBorderTile();	//$34:8c84();
}
```



