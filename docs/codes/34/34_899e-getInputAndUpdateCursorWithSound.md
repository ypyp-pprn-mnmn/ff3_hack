
# $34:899e getInputAndUpdateCursorWithSound

<summary>
各種入力ウインドウにおいて、パッド入力を取得し対応する動作を行う(十字キーなら音ともに移動・ABなら音を鳴らして戻る)
</summary>

## args:
+ [in] u8 $1a : cursorId
+ [in] u8 $1b : rightend (with this value not included)
+ [in,out] u8 $22 : col
+ [in,out] u8 $23 : row
+ [out] u8 $50[$1a] : inputBits (only a,b,left,right;otherwise unchanged)
## notes:
//[commandWindow_dispatchInput]
## (pseudo-)code:
```js
{
	$1e,1f = #8acf;
	$21 = 0;
	do {
$89aa:	
		presentCharacter();	//$34:8185();
		getPad1Input();//$3f:fbaa();
	} while ((a = $12) == 0);
$89b4:
	push (a)
	playSoundEffect18();	//set$ca_18_and_increment_$c9();	//$34:9b79();
	pop a;	//input bits
	for($21;;$21++) {
$89b9:		a >>= 1;
		if (carry) break;
	}
$89c0:	//$21 = 押されたボタンのビット番号 (A=0,B=1,)
	$1e,1f += ($21 << 1);	//$1e = #8acf
	$1e,1f = *($1e,1f)
	(*$1e)();	//funcptr
$89de:
}
```



