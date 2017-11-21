
# $35:a609 loadString

<summary></summary>

## args:
+ [in] u16 $18 : tableBase
+ [in] u8 A : index
+ [in,out] u8 X : destOffset
## notes:
テーブルに入ってる値は$18:0000(file30000)からのリニアな16bitオフセット
対象のデータがあるbankを常に$8000-$bfffにマップするので注意
## (pseudo-)code:
```js
{
	$1a = a;
	a = x; push a;
	get2byteAtBank18($1a);	// $3f:fd60();
$a610:	push (a = $18);
	push (a = $19);
	$1a,1b = #4000;
	div16();	//$3f:fc92();
	y = $1c + #0c;
	$19 = pop a;
	$18 = pop a;
	switch (y) {	//possible y : c,d,e,f (per16k bank index)
	case 0xD:
$a639:		$18,19 += #4000; break;
	case 0xE:
$a666:		break;
	case 0xF:
$a659:		$18,19 -= #4000; break;
	default:
$a649:		$18,19 += #8000; break;
	}
$a666:
	pop a;x = a;	//initial X
	a = y;
	copyTo_$7ad7_x_Until0(bank = y,offset = x);	//jmp $3f:fd4a();
$a66c:
}
```



