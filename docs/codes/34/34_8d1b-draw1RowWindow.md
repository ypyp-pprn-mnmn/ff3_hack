
# $34:8d1b draw1RowWindow


vramの指定位置にcx文字がちょうど収まる大きさの1行ウインドウを描画する


### args:
+ [in] u8 A : windowId
+ [in] u16 $7ac0 : stringPtr

### local variables:
+	Draw1LineWinowParam $8e33.x

### notes:
描画の際描画前の画像(タイル番号)を指定の場所に保存する
対象文字列の長さは特に考慮しない

### (pseudo-)code:
```js
{
	$18 = a;
	a <<= 3;	//$3f:fd3f();
	x = a + $18;	//a * 9
	$18 = $60 = $8e83.x; x++;
	$19 = $61 = $8e83.x; x++;
	$78b8 = a = $8e83.x;
	$78b9 = a + 2; x++;
	$1a = $8e83.x; x++;
	$1b = $8e83.x;
	y = 0;
	$1c = a = 4;
	for ($1c = 4;$1c != 0;$1c--) {
$8d52:		presentCharacter();	//$34:8185();
		a = $19; x = $18;
		setVramAddr();	//$3f:f8e0();
		a = $2007;

		for (x = $78b9;x != 0;x--) {
$8d62:			a = $2007;
			$1a[y] = a; y++;
		}
$8d6b:		
		$18,19 += #0020;
		setBackgroundProperty();	//$34:8d03();
	}
$8d81:
	//$1a = #f7; $1b = #f8; $1d = #f9;
	drawBorder(left=#f7,mid=#f8,right=#f9);	//$34:8de5();
	$18,19 = $7ac0,7ac1;	//ptr to string
	for ($1c = 2,y = 0;$1c != 0;$1c--) {
$8da0:		presentCharacter();	//$34:8185();
		a = $61; x = $60;
		setVramAddr();	//3f:f8e0
		$2007 = #fa;
		for (x = $78b8;x != 0;x--) {
$8db2:			$2007 = a = $18[y]; y++;
		}
$8dbb:
		$2007 = a = #fb;
		$60,61 += #0020;
		setBackgroundProperty();	//$34:8d03();
	}
$8dd6:
	//$1a = #fc; $1b = #fd; $1d = #fe;
	return drawBorder(left=#fc,mid=#fd,right=#fe);	//jmp $34:8de5();
$8de5:
}
```



