
# $35:a104 command_fight



>04: たたかう


### args:
+ [out] u8 $7edf : protectionTargetBit

### notes:
`$35:a29e`

### (pseudo-)code:
```js
{
	if (getActor2C() < 0) {	//$35:a42e()敵ならマイナス(bit7=1)
$a10c:
		x = $18 = $70[y] & 7;//y=#2c
		a = $7cec;	//nearly dead flag?
		if (maskTargetFlag(flag:a = $7cec, target:x) != 0) { //bne a11e // $a1a9;
$a11e:
			if ( ($70[y = #1] & #c0) == 0 //bne a12b
				&& ($70[++y] & #21) == 0) //a12b: bne a1a9
			{
$a12d:
				//not (dead|stone |confuse|jump)
				$22 = $52 = 0;
				for ($52;$52 != 4;$52++) {
$a133:
					x = $19 = a = $52 << 1;
					$24.x = a;
					y = updatePlayerOffset();	//$a541();
					if ( ($57[y] == #7)  //bne a165
$a145:						&& ($5b[++y] & #c1) == 0) //bne a165
$a14d:						&& ($5b[++y] & #e0) == 0) //bne a165
					{
$a153:	
						x = $19;
						setYtoOffset03();	//$9b8d();
						$1a.x = $5b[y];	//hp
						$1b.x = $5b[++y];
						$22++;
						//bne $a16d;
					} else {
$a165:
						x = $19;
						$1b.x = $1a.x = 0;
					}
$a16d:
				}
$a175:
				if ($22 != 0) { //健康なナイトがパーティにいる
$a179:
					x = getIndexOfGreatest();	//$a30f();
					$7edf = $7e99 = flagTargetBit(a = 0);	//$fd20
					$7ee0 = flagTargetBit(a = 0,x = $18);	//$fd20
					$70,71 = #7575 + $5f;
					/*
					1A:A19E:A0 33     LDY #$33
					1A:A1A0:B1 70     LDA ($70),Y @ $0001 = #$01
					1A:A1A2:8D EA 7C  STA $7CEA = #$1E
					1A:A1A5:29 FE     AND #$FE
					1A:A1A7:91 70     STA ($70),Y @ $0001 = #$01
					1A:A1A9:4C 12 A2  JMP $A212
					*/
					$7cea = a = $70[y = #33];
					$70[y] = a & #fe;	//後列フラグクリア
				}
			}
		} 
$a1a9:			
		//goto $a212;
	} else {
$a1ac:
		push a;
		a = $6e[y = #1] & #28;	//toad|minimum
		if (a != 0) { //beq a1c0
			pop a;
			$7e1f = $7e20 = 0;
		} else {
$a1c0:
		//武器チェック
		//盾か他方が素手の弓矢なら素手扱いとする
		//盾と弓か矢を同時に装備している場合弓矢の方は素手扱いされないが
		//通常弓矢と盾は同時に持てない(装備時に制限される)ので問題は起きない
			$52 = pop a & #7;
			y = updatePlayerOffset() + 3; //a541
			$7e1f = $59[y]; y+=2;
			$7e20 = $59[y];
			if ($7e1f != 0) { //beq a1e8
				if (a < #58) //bcc a1f6
$a1e1:
				//右手が盾
				$7e1f = 0;
				//beq a1f6
			} else {
$a1e8:
				if ($7e20 < #4a) a212 { //bcc a212
$a1ef:				//右手が素手で左手が弓か矢か盾
				$7e20 = 0;
				beq a212;
			}
$a1f6:
			//右手は素手以外
			if ($7e20 != 0) { //beq a206
$a1fd:
				if (a < #58) bcc a212
				//左手が盾
				$7e20 = 0;
				//beq a212
			} else {
$a206:
				if ($7e1f < #4a) bcc a212;
$a20d:
				//右手が弓か矢で左手が素手
				$7e1f = 0;
			}
		}
	}
$a212:
	dispatchBattleFunction_03();	//$34:801e();
	if ($7edf != 0) { //$a229
		$78da.(x = $78ee) = #52;	//"ナイトが みをていして かばった！"
		/*
		1A:A222:A0 33     LDY #$33
		1A:A224:AD EA 7C  LDA $7CEA = #$1E
		1A:A227:91 70     STA ($70),Y @ $0001 = #$01
		*/
		$70[y = #33] = $7cea;	//後列フラグ復元
	}
$a229:
	a = $7c + $7d;
	if (a > 32) a = 32;
	$78d7 = a;	//"nnかいヒット!" / "ミス!"
	if (a == 0) goto $a29e;	//miss!
$a23c:
	y = 2;
	if ( ($e0.(x = $64) & #80) != 0) $a29e;	//dead
$a246:
	if ( (a = ( $e0.(++x) & #18)) == 0) $a29e;	//status varied?
$a24d:
	a = (a - #8) & #18; 
	if (a == 0) { //bne $a295;
$a254:
		push (a = $e0.x)
		$70[y] = $e0.x = a & 7;	//x:+01,y:+02
		$18 = $6e[y = #2c] & #87;
		if (($18 == ($70[y] & #87) { // bne$a275; //istargetactor?
$a26d:
			$6e[y = 2] = $f0.x = $e0.x;
		}
$a275:
		pop a;
		x = 0;
$a278:		for (x;;x++) {
			a <<= 1;
			if (carry) break; //bcs a27e
		}
$a27e:		$78d9 = x + 2;	//status index + 2
		$70[y = #2c] &= #e7;	//clear mode
		$70[y = #2e] = 0;	//action id = no action
		beq a29e;
	} else {
$a295:		//statusCache02 == [#18 || #10]
		$70[y] = $e0.x = $e0.x - #8;
	}
$a29e:
	a = $e0.(x = $64) & #80; //target dead
	if (a != 0) { //beq a2b7
$a2a6:
		$78da.(x = $78ee) = #1a;	//1a:"しんでしまった!"
		if ($70[y = #2c] < 0) { //bpl a2b7
$a2b4:
			$78da.x++;	//1b:"てきをたおした!"
		}
	}
$a2b7:
	$24 = $78d5 = 0;
	if (getActor2C() >= 0) { //bmi $a30e	//$a42e();
$a2c3:
		$52 = a & 7;
		y = updatePlayerOffset + #31;	//a541
		if (($5b[y] & 4) != 0) { //beq a2dd
$a2d4:
			push (a = y);
			consumeEquippedItem(a = #4);	//$a353
			y = pop a;
		}
$a2dd:
		if (($5b[++y] & 4) != 0) { //beq a2e9
$a2e4:
			consumeEquippedItem(a = #6);
		}
$a2e9:
		setYtoOffset03();	//$9b8d();
		//#41:しゅりけん
		if ($59[y] == #41) { //bne a2f7
$a2f2:
			consumeEquippedItem(a = #4);
		}
$a2f7:
		setYtoOffsetOf(#5);	//$9b88();
		if ($59[y] != #41) $a307
$a302:
		consumeEquippedItem(a = #6);	//$a353();
$a307:
		if ($24 != 0) {
			//consumed item was last one.recalc required
			dispatchBattleFunction(5);	//$34:8026();
		}
	}
$a30e:
	return;
$a30f:
}
```



