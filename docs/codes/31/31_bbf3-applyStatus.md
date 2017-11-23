
# $31:bbf3 applyStatus



### args:
+ [in] u8 $24 : status to apply
+ [in,out] u8 $e0 : applied status
+ [in,out] u8 $78ee : queue index?
+ [out] u8 $78d9 : status index?
+ [out] u8 $78da~ : battle event queue?
+ [out] u8 a : $70[0x2c]

### (pseudo-)code:
```js
{
	x = a = (get$70_2C() & 7) << 1;	//bc25()
	if (0 == (a = ($24 & 1)) ) {
		//heavy bad status
		a = $e0.x;
		//より重いステータスになっている場合はなにもしない
		if (a >= $24) return clearEffectTarget(); //jmp $b926;
$bc09:
		$e0.x |= $24;
		x = 0;a = $24;
$bc11:		do {
			a <<= 1;
			if (carry) break;
			x++;
		} while (x != 0);
$bc17:
		a = x;
		if (a >= 0) {
			clc;
			a += 3;
		}
$bc1f:		clc;
		a += 10;
		$78d9 = a;
$bc25:		a = $70[y = #2c];
		return ;
	}
$bc2a:	//($24 & 1) == 1

	//if (0 != (a = ($24 & 0x20)) ) {
	if ((a = $7ed8) >= 0) 
		|| (0 == ($24 & 0x20)) )
	{
$bc35:
		x++;
		a = $24 & 6;	//graduallyPetrify
		if (0 == a) {
			$25 = $e0.x;
			$18 = $25 & 0xE0;	//paralyzed | sleeping | confused
			$19 = $24 & 0xE0;	//
			//より重かったらなにもしない
			if ($18 > $19) return clearEffectTarget();	//jmp $b926;
			
			$18 = $25 & 7;	//石化度|ステータス種
			$18 |= $0024 & 0xfe;
			$e0.x = $18;
			if (0 != (a = ($18 & 0x20)) ) {
$bc66:
				//混乱したので行動をキャンセル
				$70[y = #2e] = 0;
				get$70_2C();	//$bc25
				$70[y] = a & 0xE7; 
			}
$bc73:
			x = 0; a = $24;
			do {
$bc77:				a <<= 1;
				if (carry) break;
			} while (x != 0);
$bc7d:
			$78d9 = a = x + 0x0c;
			return ;
		}
$bc85:
		//徐々に石化
		$18 = $24 & 0x7E;
		$25 = $e0.x;
		$19 = $25 & 0x06;
		a = $18 + $19;
		if (a < 8) {
$bc9c:
			$e0.x = $18 + $25;
			a = $6e[y = #2e];	//action id?
			if (a == 4) {
				//行動id04(たたかう)によって徐々に石化した
				x = $78ee;
				$78da.x = #3c;	//"からだがじょじょにせきかする"
				$78ee++;
			}
$bcb6:
			return;
		}
$bcb7:
		$e0.x = a = $25 & 0xf9; x--;
		$e0.x |= #40;
		$78d9 = #0b;	//"いし"
		x = $78ee;
$bcc9:
		$78da.x = #28;	//28:"いしになりくだけちった!"
	} else {
$bc50:
		return clearEffectTarget();	//jmp $b926;
	}
}
```



