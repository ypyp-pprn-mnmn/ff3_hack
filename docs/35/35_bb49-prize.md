
# $35:bb49 prize

<summary></summary>

## args:
+ [in] u16 $57 : playerParamBasePtr (=$6100)
+ [in] u16 $5b : playerBattleParamBasePtr (=$7575)
+ [in] u8 $78f0[4][4] : playerActionCounts
+ [in] u8 $7d6b[4] : mobids
+ [in] u8 $7dd3[4] : killCounts?
+ [out] u8 $7571 : droppedItemCount
+ [out] u8 $7434[30h] : droppedItems
+	u8 $52 : playerIndex
+	u8 $53 : alivePlayerCount
+	u16 $5f : playerOffset
+	u8 $7570 : enemyGroupNo
## local variables:
+	BattlePrizeInfo $7400 : enemyInfo
## dependencies:
+	$34:8ff7 : presentBattle
+	$34:9b88 : setYtoOffsetOf
+	$34:9b8d : setYtoOffset03 (03:exp)
+	$35:a541 : calcPlayerOffset
+	$35:a564 : getSys1Random
+	$35:ba3a : loadTo7400FromBank30
+	$35:bf7c : lvupParams
+	$35:bfb3 : ? some item related routine
+	$3f:fa0e : call_2e_9d53
+	$3f:fc92 : div16
+	$3f:fcd6 : mul8x8
+	$3f:fcf5 : mul16x16
+	$3f:fd3c~41 : shiftLeftN
+	$3f:fd43~48 : shiftRightN
+	$3f:fda6 : loadTo7400Ex
## notes:
	struct BattlePrizeInfo { //@ram7400
		u8  ? $10:9c80		//00
		u16 exp; 		//01 from $10:9d80
		MobBaseParam ;		//03
		u8 dropList[8];		//13 $10:9b80[ mobparam.0F &1F ]
		u16 gil;		//1b from $30:9c58
		u8 capacity; 		//1d from $39:b2ae
	}
## (pseudo-)code:
```js
{
	call_2e_9d53(a = #0f);	//$3f:fa0e();

	$7570,7571 = 0;
	for ($52 = 0;$52 < 4;$52++) {
		y = getPlayerOffset() + 1; //$35:a541()
		a = $5b[y] & #c0;
		if (a == 0) {
			x++;
		}
	}
	$53 = x;
	$52 = 0;
	for (x=0;x < 0x34;x++) {
		$7400.x = 0;
	}
	for (x;x < 0x80;x++) {	
		$7400.x = #ff;
	}
$bb87:
	for ($7570;$7570 < 4;$7570++) {
		x = $7570
		$2c = $7dd3,x
		$32 = mobid (= $7d6b,x)
		//$18 = mobid
		//$1a = 1
		//$20 = #$9c80
		//A = 8 X = 0 Y = 1A
		//loadParamEx()
		loadTo7400Ex({
			$18_index: mob_id,
			$1a_size_of_entry: 1,
			$20_base_address_of_table: #$9c80,
			A_bank_index_of_table: 8,
			X_dest_offset: 0,
			Y_current_bank: #$1a
		})
		$18 = $7400
		$1a = 2
		$20 = #$9d80
		x = 1
		loadParamEx()
		$18 = mobid
		$1a = #$10
		$20 = #$8000 ($30:8000)
		x = #3
		loadParam()
		$18 = $7412&1f
		$1a = 8
		$20 = #$9b80
		loarParamEx(x=#$13)
		$18 = mobid
		$1a = 2
		$20 = #$9c58
		loadParam(x=#$1b)
		$18 = mobid
		$1a = 1
		$20 = #$b2ae ($39:b2ae)
		loadParamEx(x=1d,y=1a,a=1c)
		//@$7400 {
			u8  exp_table_id 	//00 $10:9c80[mob_id]
			u16 exp				//01 $10:9d80[exp_table_id]
			MobBaseParam ;		//03
			u8 dropList?[8]		//13 $10:9b80[ mobparam.0F &1F ]
			u16 gil? $30:9c58	//1b
			u8 capacity? $39:b2ae	//1d
		}
		//$18,19 = $7401,7402
		//$1a,1b = $53,#00
		$7401,7402 /= $53	//$53=生存者数
		for ($2c;$2c > 0;$2c--) {	//$2c = 敵グループ内撃破数
			$7424,7425,7426 += $7401,7402,#00
			$7427,7428,7429 += $741b,741c,#00

$bc7e:
			$2e = $7412 >> 5;	//jsr fd44
			a = getSys1Random(6);	//jsr $35:a564(a=#6)
			if (a < $2e) {	//bcs bce6
				getSys1Random(max:a = #ff);
				if (a < 30h) a = 0;	//12/64
				else if (a < 60h) a = 1;//12/64
				else if (a < 90h) a = 2;//12/64
				else if (a < c0h) a = 3;//12/64
				else if (a < d8h) a = 4;// 6/64
				else if (a < f0h) a = 5;// 6/64
				else if (a < fch) a = 6;// 3/64
				else a = 7;		// 1/64
				
				a = $7413[a] 
				if (a != nullItem) {	//beq bce6
					incrementItem();	//$bfb3();
					if ( (carry)  //bcc bce6 
						&& ((x = $7571) < 30h) ) //bcs bce6
					{
							$7434,x = a; $7571++;
					}
				}
$bce6:
			}
			$742a += $741d
		}
	}
	$601c,601d,601e += $7427,7428,7429
	if ($742a != 0) {
		$742a = 1 + $742a>>2; //jsr $fd47 A>>=2
		if ($601b + $742a > 0xff) {
			$601b = 0xff;
		} else {
			$601b += $742a;
		}
	}
	$78d5,$7ec2 = 2;
	$78da = #2d;
	$78e4,78e5 = $7427,$7428	//gil
	//jsr $34:8ff7			//display routine
	$78da = #2e;
	$78e4,78e5 = $742a,#00		//capacity
	//jsr $34:8ff7
	$78da = #40;
	$78e4,78e5 = $7424,$7425	//exp
	
	//jsr $34:8ff7
	for ($3c = 0;;$3c++) {
		var item = $7434[$3c];
		if (item == 0xFF) break;
		$78e4 = item
		$78da = #29
		//おたから : xxxxxxxx
		//jsr $34:8ff7
	}
$bd9b:
	for ($52;$52 < 4;$52++) {	//$52は $35:bb71 で 0に初期化
		getPlayerOffset();	//$5f = $52 << 6;	//$35:a541()
		y = $5f + 1;
		a = ($5b),y & #c0;	//石化か死亡なら飛ばす?
		if (a != 0) cotinue; //jmp $35:bf70
		
		//熟練度上昇処理
		$1e,1f,20 = #0
		$1c = $52 << 2;	//jsr $fd40 a<<=2
		setYtoOffsetOf(a = #35);	//9b88
		$22 = ($5b),y	//2bit値の係数?
		for ($20;$20 != 4; $20++) {
			$23 = #0;
			$22,23 <<= 2;
			a = $78f0.$1c;	//$1c = playerNo * 4
			x = $23;
			$1a,1b = mul8(a,x); //$3f:fcd6()
			$1e,1f += $1a,1b
			$1c++;
		}
$bdf0:
		$1e,1f <<= 2;	// asl,rol
		setYtoOffsetOf(a = #11);	//$9b88
		$1e,1f += ($57),y , #00

		$1e,1f -= 100;
		if ( $1e,1f >= 0 ) {
			($57,y) = 0;
			y--;
			a = ($57,y) + 1;
			if (a < 99) {
				($57,y) = a;
				$78d5,$78d6 = #04,$52;
				$78da = #22;
				//じゅくれんどアップ!
				//jsr $34:8ff7
			}
		}
$be39:
		setYtoOffset03();
		//add exp
		$57[y] = $2f = $7424 + $57[y++];	
		$57[y] = $30 = $7425 + $57[y++];
		$57[y] = $31 = $7426 + $57[y];
		y -= 2;		
		if ($57[y] - #98967f >= 0) {	//#98967f =  999999999
			$57 = $2f = #98997f	//#98997f = 1000000767
		}

		y = $5f + 1;
		$18 = x = a = $57[y];	//LV
		$1a = #3;
		$20 = #$a0b0;
		//loadParamEx(a=#1c,x=#1e,y=#1a);
		$741e,741f,7420 = $39:a0b0.(lv*3);
$beaa:
		if ($2f,30,31 - $741e,741f,7420 < 0) {
$beb2:
			//獲得exp加算済みExpが必要Expを超えている
			y = $5f + 1;//offset to lv
			x = $32 = a = $57[y];
			a = x = a + 1;
			if (a < 99) {
$bec3:
				$57[y] = a;
				setYtoOffsetOf(a = #14);	//$9b88
				$24 = a = $57[y];	//VIT
				a >>= 1;
				$24 += getSys1Random(vit/2); //$35:a564();
				y = $5f + 1;
				a = $57[y] << 1;	//lv
				$24 += a;
				setYtoOffsetOf(a = #0e);	//$9b88
				$57[y] += $24,#00;	//maxHP
$bef6:				
				if ($57[y] - #270f >= 0) {
					$57[y] = #270f;	//#270f = 9999
				}
				y = $5f;
				//$18 = a = $57[y];	//job
				//$1a = #c4;
				$1c = mul16(job,#c4);
				$20,21 = $1c,1d + #a1d6;
				$18 = $32;	//LV
				$1a = #2
				//loadParamEx(a=#1c,x=#21,y=#1a);
				$7421,7422 = ($39:a1d6 + job*#c4).(lv*2)
				
				a = $7421;
				lvupParams();	//$35:bf7c();

				setYtoOffsetOf(a = #31); //$9b88
				for (x = 8;x > 0;x--) {
$bf49:
					$7422 >>= 1;
					if (carry) {
						a = $57[y] + 1;	//maxMp
						if (a < 100) {
							$57[y] = a;
						}
					}
					y += 2;
				}
$bf5e:
				$78d5,78d6 = #4,$52; //playerNo
				$78da = #20
				//レベルアップ!
				//jsr $8ff7
			}	//lv < 99?
		}	//LVup?
$bf70:
	}
$bf7b:
	return;
}
```



