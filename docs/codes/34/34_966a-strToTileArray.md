
# $34:966a strToTileArray

<summary>文字列をキャラクタ番号の配列に変換する(濁点、半濁点、改行などを処理)</summary>

## args:
+ [in] u8 $18 : cchLine
+ [in] u8 $4e : destCharPtr
+ [in] u8 $7ad7[] : string (zero terminated)
## (pseudo-)code:
```js
{
	offset$4e_16(a = $18);	//$35:a558();
	y = 0;x = 0;
	for (;;x++,y++) {
$9673:	
		$1c = a = $7ad7.x;
		if (a == 0) return;
$967b:
		elif (a == #ff) $96ef;	//(space)
		elif (a == #01) $9735;	//(\n)
		elif (a == #02) $9745;	//
		elif (a == #42) $96b2;	//ヴ
		elif (a >= #60) $96f1;	//(盾マーク;ポの次)
		elif (a >= #57) $96df;	//パ
		elif (a >= #52) $96cf;	//バ
		elif (a >= #43) $96ca;	//ガ
		elif (a >= #3d) $96c2;	//ぱ
		elif (a >= #38) $96ba;	//ば
		elif (a < #29) $96f1;	//が
$96ad:		putDakuten(); goto $96c5;	//always satisfied
$96b2:		putDakuten(); a += #8a; goto $96f1;
$96ba:		putDakuten(); a += #6b; goto $96f1;
$96c2:		putHandakuten();
$96c5:		a += #66; goto $96f1;
$96ca:		putDakuten(); bne $96e2;
$96cf:		putDakuten(); 
		if (a == #55) { a = #a6; goto $96f1; }	//'べ'
$96da:		a += #91; goto $96f1;
$96df:		putHandakuten();
$96e2:		if (a == #5a) { a = #a6; goto $96f1; } //'ぺ'
$96ea:		a += #8c; goto $96f1;
$96ef:		a = #ff;
$96f1:	
		$4e[y] = a;
	}
$96f8:
}
```



