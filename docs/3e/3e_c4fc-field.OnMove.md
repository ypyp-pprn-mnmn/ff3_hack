
# $3e:c4fc field::OnMove


## args:
+	[in] u8 $42 : vehicle 
	-	(0-歩行、1-チョコボ、2-カヌー 3-船、4-飛空艇、5-シドの飛空艇
		6-ノーチラス、7-インビンシブル) 未確認
+	[in] u8 a : input
## code:
```js
{
	if ((x = $42) < 2) { //bcs $c52b
		$c65d();
		if (!carry) { //bcs $c51b
$c507:
			if ($42 != 0) { //beq $c50f
				if ($44 < 0) $c4e6;	//bit bmi
			}
$c50f:
			if ($e4 != 0) $c4e6;
			$c603();
			if (carry) $c4e6;
$c518:
			goto $c4ef;
		}
$c51b:
		if ($42 != 0) $c4e6;	//bne
		$c5de();
		if (!carry) $c4eb;	//bcc
$c524:
		$c61b();
		if (!carry) $c4eb;	//bcc
		goto $c4e6();
	}
	//
$c52b:	//[ (x = $42) >= 2]
	if (equal) { // bne $c541
		//カヌー
		$c65d();
		if (!carry) $c4ef
		$c5b5();
		if (!carry) $c4eb
		$c61b();
		if (!carry) $c4eb
		goto $c4e6	//bcs
$c53e:
		goto $c4b8;	//jmp
	}
$c541:
	if (x == 3) { //bne c556
		$c65d();
		if (!carry) $c53e;
		$c5de();
		if (!carry) $c4eb;
		$c5b5();
		if (!carry) $c4eb;
		else $c4e6;	//bcs
	}
$c556:	//vehicle= 4,5,6,7
	$c65d();
	if (carry) $c4e6
	if ($78 != 0) { //beq c566
		if (a == 4) $c598;	//海中
		goto $c966;
	}
$c566:
	//浮遊大陸?
	if (x == #c8) { //bne c590
		$600c = $27;
		$600d = $28;
		$79 = #19;
		$7a = #d7;
		a = $6021 & #20;
		var temp = a < 1 ? 0 : 1
		$7b = 2 + temp;
		$44 = #c0;
		goto $c4ef;
	}
$c590:
	$c603();
	if (!carry) goto $c4ef;	//bcs c59b
$c598:	goto $c4ef;
$c59b:	goto $c4e6;
$c59e:
}
```




