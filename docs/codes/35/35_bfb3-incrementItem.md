
# $35:bfb3 incrementItem



### args:
+ [in] u8 a : itemid
+ [out] bool carry : succeeded (1)

### notes:
	指定されたidをもつitemの数を1個増やす
	同じidのitemがなければ空欄を見つけてそこに置く
	もしみつからなければcarryをクリアして戻る
	同じidがありかつ99個以上の場合indexを1つ後ろにずらしたまま
	空欄(0)を探すので本来item32個分で終わるはずの検索も
	(60c0-61bfの奇数アドレスのどれかが0になるまで)終わらず
	0だったアドレスの次の値が1増える
	(item欄ならitemid,最後のitemなら先頭のキャラのjob)
	

### (pseudo-)code:
```js
{
	$18 = a;
	for (x = 0;x != #40; x += 2 ) {
		if ($60c0.x == $18) { //bne bfcf
$bfbe:
			x++;
			a = $60c0.x + 1;
//$bfc7: B0 0E bcs $bfd7 => B0 25 bcs $bfee (fail) or B0 0C (try to find freespace)
			if (a < 100) { //bcs bfd7
$bfc9:
				$60c0.x = a;
				sec bcs $bfef
			}
		}
$bfcf:
	}
$bfd5:	//same id not found
	for (x = 0;x != #40; x+=2 ) {
$bfd7:	
	//if same item found but its incremented amount >= 100,improperly jumps to here
		if ($60c0.x == 0) { //bne bfe8
$bfdc:
			$60c0.x = $18; x++;
			$60c0.x++;
			sec bcs $bfef
		} 
	}
$bfee:
	clc;
$bfef:
	return a = $18;
$bff1:
}
```



