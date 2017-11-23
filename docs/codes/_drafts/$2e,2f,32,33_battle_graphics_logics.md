# $2e:9d50 

### code:
```js
{
	return $9d5f();
}
```

________________________
# $2e:9d53 presentSceneThunk

### args:
+	[in] u8 A : $af4e_param
+	[in] u8 $52 : charIndex ($af4e_param)

### code:
```js
{
	jmp $9d59
}
```

________________________
# $2e:9d56 

### code:
```js
{
	return initBattle();	//$9e8e();
}
```

________________________
# $2e:9d59 

### code:
```js
{
	x = $52;
	return presentScene();	//jmp $2f:af4e();
}
```

________________________
# $2e:9d5f 

### args:
+	[in] encounter_params $7d67
+	[in] enemy_graphics_params[4] $7d73

### code:
```js
{
	$9e64();
	$9d88();
	$a9ed();   //load player sprites
	render_enemy_graphics();   //$a14a();   //load enemy patterns
	// $7d68: spawn_param_id
	if (($7d68 << 1) >= 0) { //bmi 9d75
		a = #20;
	} else {
$9d75:
		if (($7d73 & #1f) == #08) { //bne 9d82
			a = #28;	//くも
		} else {
$9d82:
			a = #2a;
		}
	}
$9d84:
	$fae9();
	return;
$9d88:
}
```

________________________
# $2e:9e8e initBattle

### args:
+	[in] u8 $7ced : encounterId
+	[in,out] u8 $7ed8 : 

### code:
```js
{
	if ((a = $7ed8) != 0) { //beq 9e95
		a = 1;
	}
$9e95:
	$7cee = a;
	$7e = $7ed8;
	push (a = $7cef);
	$7cef = a & #1f;
	$7ed8 = pop a & #e0;
	if (($74c6 >= 4)  //bcc 9ebe
		&& $7e != 4) //beq 9ebe
	{
$9eb9:
		$7cef = 6; 
	}
$9ebe:
	$7cf6 = #17;
	//a = 0;
	$4015 = 0;
	$2000 = $2001 = 0;
	$7cf3 = 0;
	$c9 = $ca = 0;
	$b8 = $ac = 0;
	$00 = 0;
	$7e8e = $7e95 = $7ee2 = 0;
	$a9 = $aa = 0;
	$05 = $01 = 0;
	$cb = $cc = 0;
	for (x = 4;x != 0;x--) {
		$7dc0.x = 0;
		$7da2.x = 0;
		$7dd2.x = 0;
		$7e21.x = 0;
		$0b.x = 0;
		$7d96.x = 0;
	}
$9f06:
	$10 = $11 = $09 = $0a = $0b = 0;
$9f12:
	$06 = $07 = #88;
	$08 = #99;
	$04 = #10;
	$03 = #97;	//irq countdown
$9f22:
	$9f8d();
	$9f98();
	initBattleRandom();	//$fc27();
	loadEnemyGroups();	//$a02a();
	$9faa();
	createIndexToGroupMap(); //a31f
	getEnemyCounts();	//$b909();
	for (x = 0;x != 8;x++) {
		$7ecd.x = $7da7.x;
	}
$9f44:
	$7ed8 |= ($7d68 >> 6) & #03;
	$2000 = $06 | #80;
	for (x = 0;x != #24;x++) {
$9f60:
		$7ee3.x = $9f6c.x;
	}
	return;
}
```

________________________
# $2f:9faa ()

### code:
```js
{

}
```

________________________
# $2f:a02a loadEnemyGroups

### args:

#### in
+	$7ced,7cee : encounter_id?
+	$2e:8000 : encounter_params { enemy_party_id, spawn_param_id }[512]
	-	index: encounter_id
+  $2e:8400 : enemy_party_table { palette_ [2], enemy_id[4] }[256]
	-	index: enemy_party_id
+  $2e:8a00 : spawn_param_table { {u4 min,max}[4] }[64]
	-	index: spawn_param_id

#### out
+	encounter_params            $7d67 : loaded_encounter_params
+	enemy_party_table           $7d69 : loaded_enemy_party
+	u8[4]                       $7d6f : number of the enemy spawned
+	enemy_graphics_params[4]    $7d73 : loaded_enemy_graphics_params

### code:
```js
{
	$7e,7f = $7ced,$7cee
	$7e,7f <<= 1;
	$7e,7f += #8000;

	$7d67 = $7e[y = 0];
	$7d68 = $7e[++y];

	mul8x8_reg(a = $7d67,x = 6);	//$f8ea();
	$7e,7f = (a,x) + #8400;
	//7e = pEnemyParty (8400-)
	for (y = 0;y != 6;y++) {
$a066:
		$7d69.y = $7e[y];
	}
$a070:
	for (x = 0,y = 0; x != 4; x++, y+= 2) {
$a074:
		a = $7d6b.y;
		load_enemy_graphics_params( enemy_id: a ); //$a0e7
		$7d73.y = $7e;    // graphics_id
		$7d74.y = $7f;    // 
	}
$a08b:
	$7e,7f = $7d68 & #003f;
	$7e,7f <<= 2;
	$7e,7f += #8a00;
	//7e = pEnemyNumberTable
$a0ab:
	for (y = 0;y != 4;y++) {
		$7d6f.y = $7e[y];
	}
$a0b7:
	for (x = 0;x != 4;x++) {
		$7d6f.x = randomizeEnemyCount(a = $7d6f.x);	//a0c8
	}
	return;
$a0c8:
}
```

________________________
# $2f:a0c8 randomizeEnemyCount

### code:
```js
{
	$7e = a;
	push (a = x);
	$21 = 0;
	x = ($7e & #f0) >> 4;
	a = $7e & #0f;
	$7e = getBattleRandom(system:$21, min:x ,max:a );
	x = pop a;
	a = $7e;
	return;
$a0e7:
}
```

________________________
# $2f:a0e7 load_enemy_graphics_params

### args:
+	[in]  a : enemyId
+	[in] u8 $2e:8b00(5cb00) : enemy_to_graphics_id ([aaabbbbb])
+	[in] u8 $2e:8f00(5cf00) : some flag for enemy (1-bit per record, lower id stored in higher bit)
+	[out] u8 $7e : graphics_id (= $2e:8b00[ enemy_id ])
+	[out] u8 $7f : ($2e:8b00[ enemy_id ] & 0x1f) + offset
	-	where offset:
		-	$7e&#e0 == #20 then #10
		-	$7e&#e0 == #60 then #18
		-	otherwise #00
+	[out] u8 $80 : msb contains bit of $2e:8f00[ enemy_id >> 3 ] >> (enemy_id & 7)

### code:
```js
{
	$7e = a;
	push (a = x);
	push (a = y);
	if ((a = $7e) == #ff) { //bne a0fc
		//empty
		$7f = $7e = #ff;
		//jmp a145
	} else {
$a0fc:
		x = $81 = a;
		$7e = $8b00.x;
		$80 = a & #1f;
		if (($7e & #e0) == #20) { //bne a115
$a110:
            // 4x6 size
			a = #10;
			//jmp a120
$a115:		} else if (a == #60) { //bne a11e
$a119:
            // 6x6 size
			a = #18;
			//jmp a120
		} else {
$a11e:
			a = 0;
		}
$a120:
		$7f = a + $80;	//enemyId & 1f + a
		$80 = $81 & 7;	//enemyId & 7
		y = $81 >> 3;	//enemyId >> 3
		x = $80;	//enemyId & 7
		$80 = 0;
		x++;
		a = $8f00.y;
		for (x;x != 0;x--) {
$a13b:
			a <<= 1;
			ror $80;
		}
$a141:
		a &= #80; a |= $7f; //? 意味が無い
	}
$a145:
	y = pop a;
	x = pop a;
	return;
}
```

________________________
# $2f:a14a render_enemy_graphics() 

### code:
```js
{
    load_enemy_patterns();  //a37f;   // load patterns
    a362;
    a247;
    a6b1;
    af34;
    a1f9;
    return a1f4;
}
```

________________________
# $2f:a1b9 loadSprites?

### args:
+	[in] u8 a : loadParamIndex
+	[in] ptr $7e : 

### code:
```js
{
	mul_8x8reg(a, x = 6);	//$f8ea
	$18,19 = #a15f + (a,x);	//$a15f: LoadToVramParams
	push (a = y);
	$7e,7f += $18[y = 0,1];	//srcOffset	//r,l:$b000
	$80,81 = $18[y = 2,3];	//destVram	//r:$1490 l:$1510
	$82 = $18[++y];		//size		//r,l:$08
	$84 = $18[++y];		//srcBank	//r,l:$15
	copyToVramDirect();	//$f969();
	y = pop a;
	return;
}
```

________________________
# $2f:a31f createIndexToGroupMap

### args:
+  [in]
+	u8      $7d7b : enemy_graphics_layout_id
+   u8[4]   $7d6f : number_of_enemies_spawned
+	[4]     $a4da : { u8[4] placement }

### code:
```js
{
	a = #ff;
	for (x = 8;x != 0;x--) {
		$7da6.x = a;
		$7dae.x = a;
	}
	$7e,7f = ($7d7b << 2) + #a4da;
$a33e:
	for (y = 0;y != 4;y++) {
		if ((a = $7e[y] ) != #ff) { //beq a346
			$8c = a;
		}
$a346:
		for ($82 = $7d6f.y ; $82 != 0; $82--) { //beq a35c
			x = $8c;
			$7daf.x = $7da7.x = y;
			$8c++;
		}
$a35c:
	}
}
```

________________________
# $2f:a37f load_enemy_patterns() 

### code:
```js
{
    for ( x = 0; x != 4; x++ ) {
        $86 = x;
        load_enemy_pattern(x);  //$a38c;
    }
}
```

________________________
# $2f:a38c load_enemy_pattern()

### args:
+	[preserved] x
+	[in] u8      x       : group_index
+	[in] u8[4]   $7d6b   : enemy_id
+	[in] u8      $7d7b   : enemy_graphics_layout_id

### code:
```js
{
    if ( $7d6b[group_index] == #ff ) {
        return;
    }
    x <<= 1;
    if ( $7d7b == #09 ) {
        load_enemy_graphics_for_layout9();  //$a3ab
    } else {
        get_enemy_pattern_address_and_copy_pattern_to_vram(x);  //$a42e
    }
    
}
```

________________________
# $2f:a3ab load_enemy_graphics_for_layout9()

### args:
+  [in] u8 $7d68    : spawn_param_id

### code:
```js
{
    a = $7d68 << 1;
    if ( a >= 0 ) { //bmi a3b7
        get_enemy_graphics_address_for_layout9();   //a3b8
        $a40b();
    }
$a3b7:
}
```

________________________
# $2f:a3b8 get_enemy_graphics_address_for_layout9()

### args:

#### in
+	x               : group_index * 2
+	u8 $86          : group_index
+	u16[?] $9068    : offsets (in per 8x8pixel tiles)

#### out
+  u16 $7e : source_addr
+  u16 $80 : dest_vram_addr (= 0x0700)
+  u8  $82 : length (= 0x90 (= 0x0c * 0x0c))
+  u8  $84 : source_bank
+  u8  y   : enemy_graphics_id * 2

### code:
```js
{
}
```

________________________
# $2f:a40b ()

### args:

#### in
+	u8 $78c3        : encounter_mode
+	u16[4] $9068    : ?
+	u8 y            : enemy_graphics_id * 2

### code:
```js
{
    if ( ($9069[y] & 0x10) == 0 ) {
        return copy_to_vram_with_encounter_mode(); //$3f:f942();
    }
    push $78c3;
    
    $78c3 = ($78c3 == 0x88) ? 0x00 : 0x88;
    copy_to_vram_with_encounter_mode();
    
    pop $78c3;
}
```

________________________
# $2f:a42e get_enemy_pattern_address_and_copy_pattern_to_vram()

### notes:
(a,b) := lower bytes first.

### args:

#### in:
+	x:          group_index * 2
+	u8 $86:     group_index
+	enemy_graphics_params[4] $7d73: loaded_graphics_params
	+	graphics_id must be < 0xc0

### out
+  u16 $7e : source_addr
+  u16 $80 : dest_vram_addr
+  u8 $82 : size_flags
+  u8 $84 : source_bank
+  u8 $86: next_group_index
+  u8 $88 : enemy_graphics_id
+  u16 $8a : source_offset (from $a4b4)

### static references:
+  u16[4] $a4a4: group_index_to_dest_vram_addrs
+  u16[4] $a4ac: group_index_to_dest_vram_addrs (for enemies which have the flag's bit5-7 set)
+  [6] $a4b4: enemy_graphics_size_params { u16 offset, u8 bank, u8 size_index }
+  [7] $a4cc: enemy_graphics_sizes { u8 width, u8 height } // metrics in tiles

### code:
```js
{
    $88 = a = $7d73.x;
    y = (a & #e0) >> 3; // logically >> 5 << 2
    ($8a,8b,84) = ($a4b4,a4b5,a4b6)[y];
    y = [$a4b7][y] << 1;
    (a, x) = ($a4cc,a4cd)[y];       //a,x = width, height
    mul_8x8_reg(a,x);               //$3f:f8ea() width*height
    $82 = a;                        //lower 8bits of width($a4cc)*height($a4cd)
    ($18,19) = (a, x);              //$18,19 = (width * height) * 16
    ($18,19) <<= 4;                 //
    ($1a,1b) = ($88 & #1f, #00);    //$1a,1b = (graphics_index & 0x1f)
    mul_16x16();                    //$1c,1d = ($18,19)*($1a,1b)
    // source_addr =
    //      base_addr + ((width * height) * 16 * (graphics_index & 0x1f))
    //
    ($7e,7f) = ($1c,1d) + ($8a,8b); //$1c,1d: $18,19*$1a,1b
    x = $86 << 1;
    $86++;
    if ( 0 == ($88 & #e0) ) {
        // 4x4 tiles の場合
        x += 8;
    }
$a497:
    ($80,81) = ($a4a4,a4a5).x;
    return copy_to_vram_with_encounter_mode(); //$3f:f942();
}
```

________________________
# $2f:a6b1 

### code:
```js
{
	$a857();
	$a697();
	y = $7d7b << 1;
	$18,19 = $a5e6.y;
	for (x = 0;x != 8;x++) {
$a6c8:
		if ($18[y = 0] == #ff) break; //beq a6ef
$a6d0:
		if ($7da7.x != #ff) { //beq a6dd
			$a6f0();
			$a78d(); //
		}
$a6dd:
		$18,19 += 3;
	}
$a6ef:
}
```

________________________
# $2f:a738 flashEnemy

### code:
```js
{
	$a697();
	$a6b1();	//?
	y = 0;
	a = $7e8f;
	for (y;y != 8;y++) {
$a743:
		a <<= 1;
		if (carry) { //bcc a74f
			push a;
			push (a = y);
			$a75a();
			y = pop a;
			pop a;
		}
	}
	$7e8e = 0;
	return;
$a75a:
}
```

________________________
# $2f:a78d 

>bug

### args:
+	green dragon = 7d7b = 09 (bug:0F)
+	[in] ptr $18 : ptr to some 3bytes data from $a5e6[$7d7b]

### code:
```js
{
	$8c = $18[y = 0];
	$8e = $18[++y];
	$90 = $18[++y];
	push (a = x);
	y = $90 << 1;
	$1e,1f = $a4cc.y, $a4cd.y;
$a7ad:
	do {
		x = 0;
		do {
$a7af:
			$a6fb();
			$82 = a;
			$7e = x + $8c;
			$80 = $8e;
			$a7d4();
$a7c1:
			x += 2;
		} while (x != $1e);
		$8e += 2;
		$1f -= 2;
	} while ($1f != 0);
$a7d1:
	x = pop a;
	return;
$a7d4:
}
```

________________________
# $2f:a7d4 

### code:
```js
{
	push (a = x);
	push (a = y);
	$7f = $7e >> 2;
	$84 = ($80 & #fc) << 1 + $7f;
	$86 = $7e & 2;
	$86 = (($80 & #02) << 1) + $86) >> 1;
	a = $82 & #03;
	x = $86;
	while (x != 0) {
		a <<= 2;
		x--;
	}
$a806:
	$87 = a;
	x = $84; y = $86;
	$7d27.x = ($7d27.x & $a81c.y) | $87;
	y = pop a;
	x = pop a;
}
```

________________________
# $2f:a8ea loadBlowEffectParams

### code:
```js
{
	mul_8x8reg(a = $7e1f, x = 3);	//$f8ea
	$7e,7f = #9098 + (a,x)
	$7e1f = $7e[y = 0];
	$7e13 = $7e[++y];
	$7e14 = $7e[++y];
	//
	mul_8x8reg(a = $7e20, x = 3);	//$f8ea
	$7e,7f = #9098 + (a,x)
	$7e20 = $7e[y = 0];
	$7e15 = $7e[++y];
	$7e16 = $7e[++y];

	mul_8x8reg(a = $7e13, x = #10);
	$7e,7f = (a,x);
	a = 2;
	loadSprites();	//$a1b9();

	mul_8x8reg(a = $7e15, x = #10);
	$7e,7f = (a,x);
	a = 3;
	loadSprites();	//$a1b9();

	$7e17 = $7e14;
	$7e18 = $7e16;
	return;
}
```

________________________
# $2f:a9cf loadActorSprite?

### args:
+	[in] u8 x : actorIndex? 
+	[in] u8 $7d8b : ?

### code:
```js
{
	push (a = x);
	if ($7d8b.x != #ff) {	//beq a9ea
		$7e = a;
		$ab3d();
		$7e,7f = $1c,1d

		loadSprites(loadUsing:a = #5, base:$7e );	//;$a1b9();
	}
	x = pop a
	return;
}
```

________________________
# $2f:ab3d 

### args:
+	[in] u8 $7e : index
+	[out] ptr $1c : dataAddr

### code:
```js
{
	push (a = x);
	if ($7e != #18) { //beq ab54
		if (a == #19) { //beq ab5f
$ab49:
			$1c,1d = #bf00
			//jmp ab7d
		}
	}
$ab54:
	$1c,1d = #bf80
	goto $ab7d;	//jmp ab7d
$ab5f:
	$18 = a;
	$19 = 0;
	$1a = #a0;
	$1b = 2;
	mul16x16();	//fcf5
	$1c,1d += #8000;
$ab7d:
	x = pop a;
	return;
$ab80:
}
```

________________________
# $2f:ad78 

### code:
```js
{
    $7cf3++;
    $09 = $0a = $0b = 0x1e;
    updatePpuDmaScrollSyncNmiEx();  //3f:f8b0;
    $f809();
    $ae5e();
$ad8e:
    for ( x = 0; x != 7; x++ ) {
        $ad9a();
        $adc0();
    }
}
```
$ad9a:

________________________
# $2f:aedf dispatchEffectFunction 

### code:
```js
{
	a = 0;
$aee1:	return call_32_8000();	//$3f:f854
$aee4:	a = 1; goto $aee1;
$aee8:	a = 2; goto $aee1;
$aeec:	a = 3; goto $aee1;
$aef0:	a = 4; goto $aee1;
$aef4:	a = 5; goto $aee1;
$aef8:	a = 6; goto $aee1;
$aefc:	a = 7; goto $aee1;
$af00:	a = 8; goto $aee1;
$af04:	a = 9; goto $aee1;
$af08:	a = #a; goto $aee1;
$af0c:	a = #b; goto $aee1;
$af10:	a = #c; goto $aee1;
$af14:	a = #d; goto $aee1;
//...
$af30:	a = #14;goto $aee1;
//...
$af44: a = #19; goto $aee1;
}
```

________________________
# $2f:af48 is_backattacked_2f()    

>is$78c3_#88

### args:
+	[in] u8 $78c3    : encounter_mode
+	[out] bool zero   : 1: back-attacked

### code:
```js
{
	return ($78c3 == #88);
}
```

________________________
# $2f:af4e presentScene	

>invoke$af74

### args:
+	[in] u8 A : commandId (00-25h)
	-	01 : さがる(char:$52)
	-	02 : 指示するキャラが前に出る(char:$52)
	-	03 : playEffect_05 (back(03) )
	-	04 : playEffect_04 (forward(02) )
	-	07 : playEffect_0e(死亡・味方)
	-	08 : $b38b 行動終了したキャラを元の位置まで戻す
	-	09 : $b38e 行動中のキャラを示す(一定のラインまで前に出る)
	-	0a : playEffect_0e(死亡・敵 $7e=死亡bit(各bitが敵1体に相当) )
	-	0b : playEffect_0e
		-	(蘇生? bitが立っている敵の枠に敵がいたならグラ復活
		-	 生存かつ非表示の敵がいたとき $7e=生存bit で呼ばれる)
	-	0C : 敵生成(召還・分裂・増殖) playEffect_0F (disp_0C)
	-	0d : playEffect_0c (escape(06/07) : $7e9a(sideflag) < 0)
	-	0e :
	-	0F : prize($35:bb49)
	-	10 : 対象選択
	-	12 : 打撃モーション&エフェクト(char:$52)
	-	13 : presentCharacter($34:8185)
	-	14 : playEffect_00 (fight/sing 被弾モーション?)
	-	15 : playEffect_06 (defend(05) )
	-	16 : playEffect_09 (charge(0f) 通常)
	-	17 : playEffect_09 (charge(0f) ためすぎ)
	-	18 : playEffect_07 (jump(08) )
	-	19 : playEffect_08 (landing(09) )
	-	1a : playEffect_0a (intimidate(11) )
	-	1b : playEffect_0b (cheer(12) )
	-	1c : playEffect_0F (disp_0C) ダメージ表示?
	-	1d : playEffect_01 (command13/ cast/item)
	-	1f : playEffect_00 行動する敵が点滅
	-	20 : playEffect_00 (fight/sing 敵の打撃エフェクト?)
	-	21 : playEffect_0d (escape(06/07) : $7e9a(effectside) >= 0)
	-	22 : playEffect_01 (magicparam+06 == #07)
	-	23 : playEffect_01 (magicparam+06 == #0d)
	-	24 : playEffect_0c (command15)
+	[in] u8 X : actorIndex
+	[out] u8 $7d7d : 0

### local variables:
+	u16 $2f:af74 : functionTable

### notes:
各種ゲームシーン表示系のルーチンから呼ばれる

### code:
```js
{
	$93 = a;
	push (a = x);
	push (a = y);
	$95 = x;
	y = a = $93 << 1;
	$93,94 = $af74.y,$af75.y

	callPtrOn$0093();
$af69:
	$7d7d = 0;
	y = a = pop;
	x = a = pop;
}
```
________________________
# $2f:af71 callPtrOn$0093 

### code:
```js
{ 
	(*$93)();	//jmp ($0093);
}
```

________________________
# $2f:af74 $af4e_funcTable;



________________________
# $2f:b024 presenetScene_1f 

> [flashEnemy]

### code:
```js
{
	if ($7e9d != #09) { //beq b049
		for ($b6 = 0;$b6 != #08;$b6++) {
$b02f:
			if ( ($b6 & 1) == 0) { //bne b03b
$b035:
				$b04a();
			} else {
$b03b:
				$b04d();
			}
$b03e:
			$af34();
		} //bne b02f
	}
$b049:
	return;
}
```

________________________
# $2f:b04a 

### code:
```js
{
	return $a738();
}
```
________________________
# $2f:b04d 

### code:
```js
{
	return $a6b1();
}
```

________________________
# $2f:b15e presentScene_1d	

>[magic effect]


### args:
+	[in] u8 $7e9a :	side flag

### code:
```js
{
	a = $7e9a;
	if (a < 0) {
$b163:		dispatchEffectCommand(#d);	// $2f:af14();
	} else {
$b169:		moveCharacterForward();	//$2f:b38e();	//行動するキャラが前にでる
		$2f:a9cf();
		dispatchEffectCommand(#d);	//$2f:af14();
		$2f:b25b();
	}
$b175:
	a = 6;
	$2f:a1b3();
	$cc = 0;
}
```

________________________
# $2f:b1ac presentScene_1c	

>[damage]


### code:
```js
{
	dispatchEffectCommand(#0c);	//jmp $af10
}
```

________________________
# $2f:b1d8 presentScene_16	

>[charge]

### code:
```js
{
	$7e19 = 0;
	return $b1e5();
}
```

________________________
# $2f:b1e0 presentScene_17	

>[charge,fail]

### code:
```js
{
	$7e19 = 1;
$b1e5:
	moveCharacterForward();	//前に出る
	$a9cf();	//sprite読み込み?
	$a9b1();
	dispatchEffectFunction_07();	// $aefc();
	return $b25b();
}
```

________________________
# $2f:b24c presentScene_13	

>caller: $34:8185

### code:
```js
{
	dispatchEffectCommand(#03);	//jmp $aeec
}
```

________________________
# $2f:b24f presentScene_12	

>fight

### code:
```js
{
	moveCharacterForward();	//$b38e()	//まえにでる
	$a9cf();	
	loadBlowEffectParams();	// $a8ea();
	dispatchEffectFunction_04();	//$aef0();	//打撃モーション
	x = $95;
	return $b38b();	//さがる
}
```

________________________
# $2f:b25b 

### code:
```js
{
	x = $95;
	return $b38b();	//さがる
}
```

________________________
# $2f:b2fa presentScene_10	

>selectTarget

### code:
```js
{
	$a5 = x;
	$7e0f.x = 0;
	return dispatchEffectFunction_01();	//$aee4()
}
```

________________________
# $2f:b348 presentScene_0C	

>敵生成

### code:
```js
{
	return $b93a(x = $7e);
}
```

________________________
# $2f:b352 moveCharacterBack

### code:
```js
{
	$7d7d = #1;
	y = x << 1;
	if (($7d9b.y & 8) != 0) {
		$7e = #f0;
		$7d7d = 0;
		//jmp b37f
	} else 
$b36d:
		if (($7d8f.x & 1) != 0) { //beq b37b
			$7e = #20;
			//jmp b37f
		}
$b37b:
		$7e = #10;
	}
$b37f:
	$7d7f.x += $7e;
	return $b45c();
$b388:
}
```

________________________
# $2f:b38b call_b3c7

### code:
```js
{
	return $b3c7();
}
```

________________________
# $2f:b38e moveCharacterForward

### args:
+	[in] x : actorIndex
+	[in,out] u8 $7d7f[] : x?

### code:
```js
{
	$7d7d = 0;
	y = x << 1;
	if (($7d9b.y & 8) != 0) { //beq $b3a9
		//backattack?
		$7e = #f0;
		$7d7d = 1;
		//jmp $b3bb;
	} else {
$b3a9:
		if (($7d8f.x & 1) != 0) { //beq $b3b7
$b3b0:
			//backline?

			$7e = #20;
			//jmp $b3bb;
		} else {
$b3b7:
			$7e = #10;
		}
	}
$b3bb:
	$7d7f.x -= $7e;
	return $b45c();
$b3c7:
}
```

________________________
# $2f:b3c7 

### code:
```js
{
	moveCharacterBack();	//$b352();
	return $b58f();
}
```

________________________
# $2f:b45c 

### code:
```js
{
	push (a = x);
	$7cf4 = 0;
	dispatchEffectFunction_14();	//$af30();
	x = pop a;
	return;
}
```

________________________
# $2f:b58f 

### code:
```js
{
	push (a = x);
	y = a;
	$99 = $7d8b.y;
	$9a = $7d9c.y;
	$b607();
	$b5f2();
	$b72b();
	dispatchEffectFunction_02();	//$aee8();
	waitNmi();	//$fb80();
	setDmaSourceAddrTo0200();	//$f8aa();
	$b6c8();	//drawing
	updatePpuScrollNoWait();	//$f8cb();
	x = pop a;
	return;
$b5b8:
}
```

________________________
# $2f:b5f2 

### code:
```js
{
	if ( (($9a & 1) == 0) //bne b606
		&& ($99 & 8) != 0) //beq b606
	{
$b5fe:
		$7d83.x |= #80;
	}
$b606:
	return;
}
```

________________________
# $2f:b607 

### code:
```js
{
	if (($99 & #80) == 0) b61d; //beq b61d
	if (($99 & #05) == 0) b618;
$b613:
	a = #10; return $b64d();
$b618:
	a = #09; return $b64d();
$b61d:
	if (($99 & #40) == 0) $b628;
$b623:
	a = 0; return $b64d();
$b628:
	if (( $99 & #32 | $9a) == 0) $b640;
$b630:
	if (($99 & #05) == 0) $b63b;
$b636:
	a = #c;	return $b64d();
$b63b:
	a = #3; return $b64d();
$b640:
	if (($99 & #5) == 0) $b64b;
$b646:
	a = #b; return $b64d();
$b64b:
	a = #2
$b64d:
	$7d83.x = a;
	return;

}
```

________________________
# $2f:b909 getEnemyCounts

### args:
+	[out] u8 $80 : total enemy count

### code:
```js
{
	$80 = y = 0;
	for (y;y != 4;y++) {
$b90d:
		countEnemyInSameGroup($7e = y); //$b927();
		$7dce.y = a = $7f;
		$80 += a;
	}
$b921:
	$7dd2 = $80;
	return;
$b927:
}
```

________________________
# $2f:b927 countEnemyInSameGroup

### args:
+	[in] u8 $7e : groupId

### code:
```js
{
	for (x = 0;x != 8;x++) {
		$7f = x;
		if ($7da7.x == $7e) {
			$7f++;
		}
	}
	return;
$b93a:
}
```

________________________
# $2f:b93a presentEnemyGeneration

### code:
```js
{
	$7e = x;
	for (x = 0;x != 6;x++) {
		if ($7da7.x == #ff) goto $b94b;
	}
$b94a:
	return;
$b94b:
	$7ecd.x = $7da7.x = $7e;
	$b96f();
	return getEnemyCounts();	//$b909();
}
```

________________________
# $2f:b96f 

### code:
```js
{
	$a362();
	$a247();
	getEnemyCounts();	//$b909();
	$a6b1();
	dispatchEffectCommand(#15);	//$af34();
	a = #a0; x = #24;
	$ba4a();
	$b835();
	$06 |= 1;
	waitNmi();	//$fb80();
	updatePpuScrollNoWait();	//$f8cb();
	a = #a0; x = #20;
	$ba4a();
	$06 &= #fe;
	waitNmi();	//$fb80();
	return updatePpuScrollNoWait();	//$f8cb();
}
```

________________________
# $2f:ba4a 

### code:
```js
{
	$80 = a; $81 = x;
	$7e,7f = #7900;
	$86 = 7;
		//$af48();
	if ( is_backattacked_2f() ) { //bne $ba69
$ba5f:
		offset$7e(#8);	//$f8f2(8);
		offset$80(#8);	//$f8fe(8);
	}
	for ($86;$86 != 0;$86--) {
$ba69:
		waitNmi();	//fb80;
		put16hTilesFrom$7e();	//$ba8e();
		offset$7e(#20);	//$f8f2(#20);
		offset$80(#20);	//$f8fe(#20);
		put16hTilesFrom$7e();	//$ba8e();
$ba7c:
		offset$7e(#20);	//$f8f2(#20);
		offset$80(#20);	//$f8fe(#20);
		updatePpuScrollNoWait();	//$f8cb();
	}
	return;
$ba8e:
}
```

________________________
# $2f:ba8e put16hTilesFrom$7e

### code:
```js
{
	setVramAddr(high:a = $81, low:x = $80);	//f8e0
	for (y = 0;y != #16;y++) {
$ba97:
		$2007 = $7e[y];
	}
	return;
}
```

________________________
# $32:8000 invokeEffectFunction

### args:
+	[in] u8 A : effectId (00-19h)
	- 01:$9a1c selectTarget
	- 03:$9f11 presentCharacter? ($34:8185)+
	- 04:$a0c0 味方打撃
	- 0d:$bafd 魔法
	- 14:$be9a 移動

### code:
```js
{
	y = a << 1;
	$96,97 = $800f.y,$8010.y;
	return (*$0096)();
}
```
________________________
# $32:800f (6401f) invokeEffectFunction_handlers = 

### code:
```js
{
	11 91  1C 9A  D8 90  11 9F  C0 A0  B8 A8  F7 AB  27 AB
	B8 AA  15 AA  88 A9  2B A9  2B AD  FD BA  EF 8C  A4 8C
	B0 AF  89 BC  89 BE  74 BE  9A BE  FB 8E  99 A8  B7 89
}
```

________________________
# $32:89b7 effect_17


________________________
# $32:8ae6 incrementEffectFrame	

>incrementB6

### code:
```js
{
	return a = ++$b6;
}
```

________________________
# $32:8ca4 effect_0F

________________________
# $32:8cef effect_0E

________________________
# $32:8efb effect_15


________________________
# $32:90d2 is_backattacked_32() 

>is$78c3_88

### args:
+	[in] u8 $78c3
+	[out] bool zero

### code:
```js
{
	return (#88 == $78c3);
}
```

________________________
# $32:90d8 effect_02

### code:
```js
{
	fill_A0hBytes_f0_at$0200();	//$a42b();
	$c8 = #a0;
	for (x = 0;x != 4;x++) {
$90e1:
		$90ea();
	}
}
```

________________________
# $32:90ea 

### code:
```js
{
}
```

________________________
# $32:97ac 

### code:
```js
{
	$7d07 = a;
	return call_waitNmi();	//f8b0
}
```

________________________
# $32:97b2 

### code:
```js
{
	push a;
	a = $bb.(x = $cd);
	if (a == 0) { //bne 97bb
		pop a; return;
	}
$97bb:	//[hit at least once]
	if ($cb != 0 && $b7 == 0) { 
$97c3:
		a = #27;
		$97ac();
		$b7 = #f;
		$97ac();
	}
$97cf:
	y = pop a << 1;
	$7e = $97df.y;
	$7f = $97e0.y;
	(*$7e)();
}
```

________________________
# $32:98d1 showBlowSprite_02

### code:
```js
{
	getRandomizedBlowSpritePosition();	//$98e8
	y = #12
}
```

________________________
# $32:98d6 

### code:
```js
{
	if ($cd != 0) {
		y++;
	}
	$8e = y;
	return $9357();
}
```

________________________
# $32:98e0 showBlowSprite_01	

>type 0(fist) ,2(bell,book,rod,cane) ,4(harp),9(claw)

### code:
```js
{
	getRandomizedBlowSpritePosition();	//$98e8();
	y = #10;
	return $98d6();	//jmp
}
```

________________________
# $32:98e8 getRandomizedBlowSpritePosition

### args:
+	[in] u8 $b6 : frameCount

### note:
偶数フレームしか座標を更新しないので
最初に表示するフレームが奇数フレーム(全体フレーム/2=奇数)だと
一発目のみその前に殴った敵の位置に表示される

### code:
```js
{
	if (($b6 & 1) == 0) { //b6=framecount bne 9912
$98ee:
		y = ($b8 & 7) << 1;
		$8c = $7dd7[y];	//enemy.x
		$8d = $7dd8[y];	//enemy.y

		getSys0Random_00_ff();	//$a44f();
		$be = (a & #1f) + $8c;
		
		getSys0Random_00_ff();	//$a44f();
		$bf = (a & #1f) + $8d;
	}
$9912:
	$8c,8d = $be,bf
	$8f = 0;
	return;
$991f:
}
```

________________________
# $32:9a1c effectCommand_01	

>[selectTarget]

### args:
+	[in] u8 $b3 : targetingFlag (01:allowMulti 02:preferPlayerSide)

### code:
```js
{
}
```

________________________
# $32:9f11 effectCommand_03	

>[loadCharacter]

### args:
+	[in,out] u8 $b7 : tileIndexBase
+	[in] u8 $7db7 : spriteProps

### callers
+	presentScene_13 <= $34:8185

### static references:
+	u8 $9f0d = { 49 4d 51 55 }

### code:
```js
{
	a = $ac;
	if (a == 0) return;	//bne $9f16
$9f16:
	for (x = 0,$a3 = 0;x != 4;x++) {
		$a3 = x;
		$9d = $c0.x;
		$9e = $c4.x;
		is_backattacked_32();	//$32:90d2
		if (equal) { // bne $9f35;
$9f27:			$9d = a = ~$9d + #f1;
		} else {
$9f35:			a = 0;
		}
$9f37:
		$a1,a2 = a + #9efd;
		$9f = $9f0d.x;
		$a0 = x << 3;
		$9f += ($b7 & 8) >> 2;
		if (#ff == (a = $7db7.x)) $9f = a;
$9f61:
		putStatusSprites();	//$32:9fe4();
		x = $a3;
	}
$9f6b:
	putCharacterSprites();	//$32:9f71();
	$b7++;
	return;
}
```

________________________
# $32:9f71 putCharacterSprites

### args:
+	[in] u8 $b7 : ?
+	[in] u8 $7df7[2][8] : spritePos {x,y}

### code:
```js
{
	a = #f0;
	for (x = 0;x != #20;x++) {
$9f75:		$0260.x = a;
	}
$9f7d:
	x = $a3 = a = ($b7 & #18) >> 3;
	$a4 = a = $7e0f.x
	for (y = 0;y != 8;y++) {
$9f8e:
		$a4 <<= 1;
		if (!carry) continue;	//bcc $9fde
		x = a = y << 1;
		$9d = $7df7.x;
		$9d += ($a3 << 3);
		flag = is_backattacked_32();	//$32:90d2();
		if (flag) { //bne $9fb5
$9fa9:			$9d = (~$9d + #f1);
		} else {
$9fb5:			$9d += 8;
		}
$9fbc:
		$9e = $7df8.x;	//x = index<<1
		a = (x << 1) + #60;
		x = a;	//x = index*4 + #60
		$0200.x = $9e;		//sprite.y
		$0201.x = $a3 + #3a;	//sprite.tileIndex
		$0202.x = #3;		//sprite.attr
		$0203.x = $9d;		//sprite.x
$9fde:
	}
$9fe3:
	return;
}
```

________________________
# $32:9fe4 putStatusSprites

### args:
+	[in] u8 $9e : offsetY?
+	[in] u8 $9f : tileIndex? (#ff == nothing)
+	[in] u8 $a0 : destOffset
+	[in] u16 $a1 : ptr to spriteProps {y,?,attr,x}
+	[in] u8 $a3 : index of $7db7

### code:
```js
{

	for (x = $a0,y = 0;y != 8;) {
$9fe8:
		$0200.x = a = $a1[y] + $9e;	//sprite.y
		y++;
		if (#ff == (a = $9f)) {
			$0201.x = a = 0;
		} else {
			$0201.x = a;	//sprite.tileIndex
		}
$a004:
		push (a = x);
		y++;
		$a7 = $a1[y];	//y:2
		x = $a3;
		if (#ff != (a = $7db7.x)) { //beq a02f
			x = a;
			$a7 = $a7 & #fc | $a051.x;
			$a8 = $a049.x;
			x = pop a;
			push a;
			$0200.x += $a8;	//sprite.y
		}
$a02f:
		x = pop a;
		$0202.x = $a7; y++;	//sprite.attr
		$0203.x = $a1[y] + $9d;	//sprite.x	y:3
		x += 4;
		y++;
	}
$a048:	return;
}
```

________________________
# $33:a059 beginSwingFrame()	

>clearB6

### code:
```js
{
	$b6 = 0;
	return;
$a05e:
}
```

________________________
# $33:a05e fill_A0hBytes_f0_at$0200andSet$c8_0

### code:
```js
{
	$c8 = 0;
	return fill_A0hBytes_f0_at$0200();	//$33:a42b()
}
```

________________________
# $33:a065 

### code:
```js
{
	push a;
	a = x;
	$a3eb();
	pop a;
	return $a3dd();	//jmp
}
```
________________________
# $33:a06e 

### code:
```js
{
	push a;
	a = x;
	$a3dd();
	pop a;
	return $a3eb();
}
```

________________________
# $33:a077 blowEffect_swingCountBoundForWeaponTypes = 

### code:
```js
{
	07 05 05 07 05 07 07 07 07
}
```

________________________
# $33:a080 blowEffect_dispatchWeaponFunction_handlers = 

### code:
```js
{
	F2 A2  65 A3  6F A3  51 A2
	A5 A1  2C A1  25 A1  EF A1
	F2 A2  FB A2
}
```

________________________
# $33:a094 blowEffect_limitHitCountAndDispatchWeaponFunction

### code:
```js
{
	$7e = a;
	$b7 = 0;
	a = $bb.(x = $cd);
	y = $7e;
	if (a >= $a077.y) { //bcc a0af
$a0a5:
		$bb.(x = $cd) = $a077.y - 1;
	}
$a0af:
	y = $7e << 1;
	$7e = $a080.y
	$7f = $a081.y
	(*$7e)();
}
```

________________________
# $33:a0c0 effect_playerBlow 

>[effectFunction_04]

### args:
+	[in] u8 $bb : swingCountRight?
+	[in] u8 $bc : swingCountLeft?
+	[in] u8 $7e1f : righthandWeaponKind
+	[in] u8 $7e20 : lefthandWeaponKind

### code:
```js
{
	$a6c3();
	if (carry) { //bcc a0cb
		$bb = $bc = 0;
	}
$a0cb:
	$cd = 0;
	if ($7e1f == #3) { //bne a0e1
$a0d6:		if ($7e20 == #8) { //bne a0f8
$a0dd:			a = 0; goto $a0ee; //beq
		}
	} else 
$a0e1:	if ( (a == #8)		//bne a0f8
$a0e5:	  && ($7e20 == #3) )	//bne a0f8
	{
		//弓矢
$a0ec:
		a = 1;
$a0ee:
		$cd = a;
		$a24c();
		a = 3;
		return blowEffect_limitHitCountAndDispatch();	// $a094();
	}
$a0f8:
	if ($7e1f == 4) { //bne a105
$a0ff:
		//竪琴
		$a24c();
		goto a10c;
	} else {
$a105:
		if ($7e20 == 4) $a0ff;
	}
	a = $7e1f;
	blowEffect_limitHitCountAndDispatch();	//$a094();
	$cd = 1;
	a = $7e20;
	return blowEffect_limitHitCountAndDispatch();	//$a094();
}
```

________________________
# $33:a1a5 blowEffect_type04	

>[harp]

### code:
```js
{
	$a11c();
	x = $95;
	$a3f9();
	$7f49 = #8b;
$a1b2:
	beginSwingFrame();	//$a059();
	$b9 = a;
$a1b7:
	$a05e();
	if ($cd != 0) { //beq a1c8
		x = 6;
		a = #0f;
		$a06e();
		//goto a1cf
	} else {
$a1c8:
		x = #0e;
		a = #07;
		$a065();
	}
$a1cf:
	if (($b6 & 8) != 0) { //beq a1da
		a = 1;
		$97b2();
	}
$a1da:
	updatePpuDmaScrollSyncNmiEx();	//f8b0
	incrementEffectFrame();	//$8ae6
	if ((a & #10) == 0) $a1b7;
	if ($bd == 0) $a1ec;
	if (--$bd != 0) $a1b2;
	return $ac3a;	//jmp
$a1ef:
}
```

________________________
# $33:a1ef blowEffect_type07	

>[shuriken]

### code:
```js
{
	$a11c();
	x = $95;
	$a3f9();
$a1f7:	
	beginSwingFrame();	//$a059();
	$7f49 = #af;
$a1ff:
	$a05e();
	if (($b6 & #08) == 0) { //bne a220
		if ($cd != 0) { //beq a216
			x = #7;
			a = #1e;
			$a06e();
			// goto a235
		} else {
$a216:
			x = 5;
			a = #18;
			$a06e();
			//goto a235();
		}
	} else {
$a220:
		if ($cd != 0) { //beq a22e
			x = 6;
			a = #1f;
			$a06e();
			//goto a235;
		} else {
$a22e:
			x = 1;
			a = #19;
			$a06e();
		}
	}
$a235:
	updateDmaPpuScrollSyncNmiEx();	//$f8b0
	incrementEffectFrame();	//8ae6
	if ((a & #10) == 0) a1ff;
$a23f:
	$a5fe();
	return $ac35();	//jmp
$a245:
}
```

________________________
# $33:a245 getHitCountOfCurrentHand

### args:
+	[in] u8 $cd : hand (0=right,1=left)

### code:
```js
{
	$bd =$bb.(x = $cd);
}
```

________________________
# $33:a251 blowEffect_type03	

>[bow]

### code:
```js
{
	$a245();
	push (a = $7e17);
	$7e17 = $7e18;
	$7e19 = pop a;
	$a438();

	$a40f();
	x = $95;
	$a3f9();
$a26d:
	beginSwingFrame();	//$a059();
	$74f9 = #af;
$a275:
	$a05e();
	if (($b6 & 8) == 0) { //bne a2a0
		//前半(frame0-7)
	} else {
$a2a0:
		//...
	}
$a2bf:
	updatePpuDmaScrollSyncNmiEx();	//f8b0
	incrementEffectFrame();	//8ae6
$a2c5:
	if ((a & #10) == 0) $a275;
	$a6d2();
	return $ac35();

}
```

________________________
# $33:a2cf 

### code:
```js
{
	y = $95 << 1;
	return ($7d9b.y & 5);
$a2d9:
}
```

________________________
# $33:a2f2 blowEffect_type00_08	

>fist & arrow

### code:
```js
{
	if ( ($7e1f|$7e20) != 0) { //bne a2fb (blowEffect_type09)
		return;
	}
}
```
________________________
# $33:a2fb blowEffect_type09	

>claw

### code:
```js
{
	$a11c();
	x = $95;
	$a3f9();
$a303:
	beginSwingFrame();	//$a059();
	$7f49 = #8a;
$a30b:	
	fill_A0hBytes_f0_at$0200andSet$c8_0();	//$a05e();
	if ($cd != 0) { //beq a32a
$a312:
		a = 6;
		$a2d9();
		getSys0Random_00_ff();	//$a44f();
		$7e = a & 1;
		getSys0Random_00_ff();	//$a44f();
		$7f = a & 1;
		a = #0d;
		goto $a33f;
	} else {
$a32a:
		a = 5;
		$a2d9();
		getSys0Random_00_ff();	//$a44f();
		$7e = a & 1;
		getSys0Random_00_ff();	//$a44f();
		$7f = a & 1;
		a = #04;
	}
$a33f:
	push a;
	$a2cf();
	if (a == 0) { //bne a34a
$a345:
		pop a; push a;
		$92a1();
	}
	pop a;
	a = 2;
	$97b2();
	updatePpuDmaScrollSyncNmiEx();	//f8b0
	incrementEffectFrame();	//$8ae6();
	if ((a & 8) == 0) $a30b
	if ($bd == 0) $a362
	if (--$bd != 0) $a303
$a362:
	return $ac35();
$a365:
}
```
________________________
# $33:a365 blowEffect_type01	

>axe,sword,spear

### code:
```js
{
	getHitCountOfCurrentHand();	//$a245();
	$ba = 0;
	return doSwing();	//$a379();
}
```

________________________
# $33:a36f blowEffect_type02	

>bell,rod,book

### code:
```js
{
	getHitCountOfCurrentHand();	//$a245
	$ba = 1;
	return doSwing();
}
```

________________________
# $33:a379 doSwing

### args:
+	[in] u8 $bd : hitCount

### code:
```js
{
	$a438();	//getWeaponSprite?
	$a40f();	//copySpriteProps?
	x = $95;
	$a3f9();	//clearWeaponSprite?
$a384:
	beginSwingFrame();	//$a059();
	$b9 = a;	//a = 0
	$7f49 = #b6;
$a38e:
	while (($b6 & 8) == 0) {
		fill_A0hBytes_f0_at$0200andSet$c8_0();	//$a05e();
$a393:
		if (($b6 & 4) == 0) { //bne a3af
$a397:
		//前半(4フレーム)
			if ($cd != 0) { //beq $a3a5
$a39b:
				x = 2; a = 7;
				$a065();
				//goto $a3c8();
			} else {
$a3a5:
				x = 5; a = 0;
				$a06e();
			} //goto $a3c8();
		} else {
$a3af:
		//後半
			if ($cd != 0) { //beq $a3bd
$a3b3:
				x = 3;a = 6;
				$a065();
				goto $a3c3;
			} else {
$a3bd:
				a = x = 1;
				$a06e();
			}
$a3c3:
			a = $ba;
			$97b2();
		}
$a3c8:
		updatePpuDmaScrollSyncNmiEx();	//$f8b0
		incrementEffectFrame();	//$8ae6();
$a3ce:
		//if ((a & 8) == 0) $a38e; //beq
	}
	if ($bd == 0) $a3da;
	if (--$bd != 0) $a384;
$a3da:
	return $ac35();	//jmp
}
```

________________________
# $33:a3f9 clearWeaponSprite? 

>fill 18hbytes at y

### code:
```js
{
	push (a = x);
	y = $a3f5.x;
	a = #f0;
	for (x = 0;x != #18;x++) {
		$0200.y = a;
	}
	x = pop a;
	return;
$a40f:
}
```
________________________
# $33:a40f 

### code:
```js
{
	for (x = 0;x != 4;x++) {
		$7d87.x = $7d83.x;
	}
	return;
$a41d:
}
```

________________________
# $33:a42b fill_A0hBytes_f0_at$0200

### code:
```js
{
	for (x = 0,a = #f0;x != #a0;x++) {
$a42f:		$0200.x = a;
	}
}
```

________________________
# $33:a438 getWeaponSprite?

### code:
```js
{
	x = $cd & 1;
	a = $7e17.x;
	//fall through
}
```

**fall through**
________________________
# $33:a440 

### code:
```js
{
	$ab08();
	return updatePpuDmaScrollSyncNmiEx();	//$f8b0();
}
```

________________________
# $33:a446 getSys0Random

### code:
```js
{
	push a;
	$21 = 0;
	pop a;
	return getBattleRandom(max:a, min:x, sys:$21);	//$fbef();
}
```

________________________
# $33:a44f getSys0Random_00_ff

### code:
```js
{
	x = 0; a = #ff;
	return $a446();	//jmp
}
```

________________________
# $33:ac35 blowEffect_end

### code:
```js
{
	$7f49 = #$ff	//stop playing SE
	$a41d();
	$90d8();
	return updatePpuDmaScrollSyncNmi();	//$f8c5()
}
```

________________________
# $33:ac4b buildDamageSprite

### code:
```js
{
	push (a = x);
	if ($7e6f == 0) { //bne ac6c
		x = $7e72 & 3;
		$8c = $c0.x - #10;
		$8e = $c4.x - $8a + #10;
		//jmp $ac93
	} else {
$ac6c:
		if ( $7da7.x == #ff) goto $aca7; //beq
		y = a = $7e72 & 7;
		x = a << 1;
		$8c = $7dd7.x - #10;
		$7e = $ac43.y + $8a;
		$8e = $7e07.y - $7e;
	}
$ac93:
	if ( is_backattacked_32() ) { //bne aca1	//$90d2
		$8c = ($8c ^ #ff) + #df;
	}
$aca1:
	getDamageDigitTilesAndColor();	//$add1();
	setupDamageSprites();	//$acaa();
	x = pop a;
	return;
}
```

_________________________
# $33$acaa setupDamageSprites

### code:
```js
{
	x = $c8;
	a = $8e;	//y
	$acfd();
	x++;
	$0200.x = $7e;
	$0204.x = $7f;
	$0208.x = $80;
	$020c.x = $81;
	x++;
	a = $82;	//attr
	$acfd();
	x++;
	a = $8c;
	$0200.x = a; a += 8;
	$0204.x = a; a += 8;
	$0208.x = a; a += 8;
	$020c.x = a;
	if ( ($7e | $7f | $80 | $81) == 0) {
$acee:
		a = #f0; x = $c8;
		$acfd();
	}
$acf5:
	$c8 += #10;
	return;
$acfd:
}
```

________________________
# $33:ad0a getDamageValueAndFlag

### code:
```js
{
	$7e = a = x;
	y = a << 1;
	$7e70 = $7e4f.y;
	$7f = $7e50.y;
	$7e71 = $7f & #3f;
	$7e72 = ($7f & #c0) | $7e;	//higher 2bits of damage | index
	x = $7e;	//restore x
	return;
}
```

________________________
# $33:ad2b effect_0C	

>damageEffect

### args:
+	[in] u8 $7e6f : side (0 = player)
+	[in] damage $7e4f[8] : damages

		struct damage {
			u16 damage : 14;	//表示する値 3FFFで 表示無し
			u16 miss : 1;		//1なら damage == 3fffでない限りミス!と表示
			u16 heal : 1;		//1なら数字の色が緑($56-の代わりに$66-のタイルを使用,パレットは同じ)
		};

### code:
```js
{
	$cb = 0;
	a = #be;
	$a440();
	for (x = 0;x != #10;x++) {
		if ($7e4f.x != #ff) goto $ad43;
	}
	return;
$ad43:

	loadEffectSpritesWorker_base0(	a = #d );	//$bf1e();
	damagesToTiles();	//$ada6();
	beginSwingFrame();	//$a059();
	$7e73 = a;
	$90 = #8;
	$91 = #40;
	fill_A0hBytes_f0_at$0200();	//$a42b();
$ad5c:
	$c8 = 0;
	$7e73 += $90;
	x = $7e73 & #7f;
	$7ee3();	//ram
	mul8x8_reg(a, x = $91); //f8ea
	$8a = x;
	x = 0;
	do {
$ad7b:
	
		getDamageValueAndFlag();	//$ad0a();
		buildDamageSprite();	//$ac4b();
$ad81:
		if ($7e6f == 0) {
			x++;
			(x == 4);
		} else {
			x++;
			(x == 8);
		}
	} while (!equal); //bne ad7b
$ad91:
	updatePpuDmaScrollSyncNmi();	//$f8c5();
	incrementEffectFrame();	//$8ae6();
	if ((a & #10) != 0) { //beq ad9f
		$91 = #10;
	}
$ad9f:
	if (($b6 & #20) == 0) goto $ad5c;
	return;
}
```

________________________
# $33:ada6 damagesToTilesAndColor

### code:
```js
{
	for (x = 0; x != 8; x++) {
		getDamageValueAndFlag();	//$ad0a();
		damageToTilesAndColor();	//$adf4();
		y = x << 2;
		$7300.y = $7e;
		$7301.y = $7f;
		$7302.y = $80;
		$7303.y = $81;
		$7380.x = $82
	}
	return;
$add1:
}
```

________________________
# $33:add1 getDamageDigitTilesAndColor

### code:
```js
{
	x = a = $7e72 & #3f;
	y = a << 2;
	$82 = $7380.x;
	$7e,7f,80,81 = $7300.y, $7301.y, $7302.y, $7303.y;
	return;
}
```

________________________
# $33:adf4 damageToTilesAndColor

### code:
```js
{
	push (a = x);
	if ( $7e70 == #ff && $7e71 == #3f) { //bne bne $ae13
$ae04:
		$7e,7f,80,81,82 = 0;
		//goto aeab
	} else {
$ae13:
		if (($7e72 & #40) != 0) { //beq ae2f
$ae1a:
			$82 = 3;	//
			$7e = $81 = 0;
			$7f = $80 = #64;
			$80++;
			//goto aeab
		} else {
$ae2f:
			//inlined itoa_10000
$ae7a:
			if (($7e72 & #80) != 0) { //beq ae8c
$ae81:
				$18 = #66;
				$82 = #3;
				//jmp ae94
			} else {
$ae8c:
				$18 = #56;
				$82 = 3;
			}
$ae94:
			for (x = 0;x != 3;x++) {
$ae96:
				if ($7e.x != 0) break; //bne ae9f
			}
$ae9f:
			for (x;x != 4;x++) {
				$7e.x += $18;
			}
		}
	}
$aeab:
	x = pop a;
	return;
$aeae:
}
```

________________________
# $33:af6f getActionEffectLoadParam

### args:
+	[in] u8 $7e88 : actionId
+	[out] u8 $7e8b[3] : params <= $2e:91d0[actionId*3] 

### code:
```js
{
	mul8x8_reg(a = $7e88,x = 3);	//$3f:f8ea
	return memcpy(src:$7e,7f = #91d0 + (a,x), dest:$80,81 = #7e8b,
		len:$82 = 3, bank:$84 = #17); //$3f:f92f
}
```

________________________
# $33:b09b beginActionEffect

### args:
+	[in] u8 $7e88 : actionId

### code:
```js
{
	getActionEffectLoadParam();	//$33:af6f();
	push (a = $7e8b & #80);
	if (a == 0) a = #5;
	else a = #6;
$b0ac:
	loadEffectSpritesWorker_base0();	//$33:bf1e();
	a = $7e8d;
	$33:af94();
	a = $7e9a;
	if (a < 0) {
		pop a;
		return;
	}
$b0bc:
	a = $cc;
	if (0 != a) {
		pop a;
		beginSwingFrame();	//$33:a059();
		do {
$b0c4:			$33:af9f();
			setSpriteAndScroll();	//$3f:f8c5();
			incrementEffectFrame();	//$32:8ae6();
		} while (a != #20);
		return;
	}
$b0d2:
	pop a;
	if (a == 0) {	//bne $b0f1
		beginSwingFrame();	//$33:a059();
		$7f49 = #a1;
		do {
$b0dd:			$33:af9f();
			$33:b1cd();
			$33:b1f8();
			setSpriteAndScroll();	//$3f:f8c5
			incrementEffectFrame();	//$32:8ae6();
		} while (a != #2c);
	}
$b0f1:
	$33:bf5f();
	a = #10;
	$33:b35c();
	$33:b362();
	beginSwingFrame();	//$33:a059();
	$7f49 = #a1;
	do {
$b104:		$33:af9f();
		$33:b1c3();
		$33:b134();
		setSpriteAndScroll();	//$3f:f8c5
		incrementEffectFrame();	//$32:8ae6();
	} while (a != #30);
	do {
$b117:	
		$33:af9f();
		$33:b134();
		for (y = 0;y != 8;y++) {
$b11f:
			a = 1;
			$33:bf9c();
		}
$b129:
		setSpriteAndScroll();	//$3f:f8c5
		$b6++;
	} while (0 != (a = $7e26));
}
```

________________________
# $33:b19b invertHorizontalIfBackattack

### code:
```js
{
	if (is_backattacked_32()) //$32:90d2()
	{	//bne $b1b3
		$0200.x = ($0200.x ^ #ff) - 8;	//x = #ff - x - 8
		$01ff.x = ($01ff.x ^ #40);	//bit6:水平反転?
	}
$b1b3:
}
```

________________________
# $33:b276 

### args:
+	[in] u8 $cc
+	[in] u8 $7e9a

### code:
```js
{
	a = $7e9a & #c0;
	if (a != #40) return;
$b280:
	a = $cc;
	if (a != 0) return;
$b285:
	$33:af9f();
	setSpriteAndScroll();	//$3f:f8c5();
	$33:bf5f();
	$8e = $7e89;
	for (y = 0;y != 8;y++) {
$b295:		x = a = y;
		$33:a7a5();
		$33:bfb1();
		a = 0;
		$7e30.y = a;
		$7e26.y = a;
		$8e <<= 1;
		if (!carry) a = #ff;
$b2ad:		else a = 0;
$b2af:
		$7300.y = a;
	}
$b2b7:
	beginSwingFrame();	//$33:a059();
$b2ba:
	for ($8a = a = 0; $8a != 8; $8a++) {
$b2be:		x = $8a;
		a = $7300.x;
		if (a == #ff) continue;	//$b2fe;
		y = $8a;
		$33:bf7b();
		push a;
		$33:bf6f();
		push a;
		$33:bf87();
		pop a;
		x = $95;
		$8c = a + $c0.x - #10;
		pop a;
		$8e = a + $c4.x + 8;
$b2e9:
		$33:b322();
		y = a = $8a << 1;
		a = $7dd7.y;
		if (a < $8c) continue;	//$b2fe;	//bcc $b2fe
$b2f7:
		a = #ff; x = $8a;
		$7300.x = a;
$b2fe:
	}
$b306:
	$b6++;
	setSpriteAndScroll();	//$3f:f8c5
	for (x = 0;x != 8;x++) {
$b30d:
		a = $7300.x;
		if (a != #ff) $b2ba;
	}
	for (x = #0a;x != 0;x--) {
$b31b:
		setSpriteAndScroll();	//$3f:f8c5
	}
$b321:
}
```

________________________
# $33:b589 loadEffectSprites

### args:
+	[in] u8 $7e8b[3] : actionEffectLoadParam

### code:
```js
{
	a = $7e8b & #40;
	if (a == 0) a = 0; x = #96;
$b597:	else 	a = 0; x = #a6;
$b59b:
	$7e,7f = a,x;	//#9600 or #a600
	mul8x8_reg(a = $7e8c,x = #10);	//f8ea
	$7e,7f += a,x;
	loadEffectSpritesWorker(a = 7);	//bf24
	return loadEffectSpritesWorker_base0(a = 8); //bf1e
}
```

________________________
# $33:b64f presentEffectAtTarget

### args:
+	[in] u8 $90 : current target index
+	[in] u8 $7300[0x100] : effectFrameParams
+	[in] u8 $7e9a :	actor's char index?
+	[in] u8 $7eb8 : reflected target bits

### code:
```js
{
	$7eb8 <<= 1;
	if (!carry) {	//bcs $b657
		return presentEffectAtTargetWorker();	//$33:b6f3();
	}
$b657:
	$33:a440(a = #b1);
	$33:b5bb();
	$33:a440(a = $7e8d)
	push (a = $90);
	push (a = $7e9a);
	$7e9a = a ^ #40;
	y = 0;x = $90;
	a = $7eb9.x;
	do {
$b678:	
		if (a == $fd24.y) break;
	} while (++y != 0);
$b680:
	$90 = y;
	presentEffectAtTargetWorker();	//$33:b6f3();
	$7e9a = pop a;
	$90 = pop a;
	return;
}
```

________________________
# $33:b68d presentActionEffect

### args:
+	[in] u8 $7e88 : actionId
+	[in] u8 $7e9b : targetIndicatorFlag (see $34:9de4 executeAction)

### code:
```js
{
	$7e89 = $7e9b;
	loadEffectSprites();	//$33:b589();
	mul8x8_reg(a = $7e88,x = 2);	//$3f:f8ea();
	memcpy(dest:$80 = #7300, src:$7e = #8c00+(a,x), len:$82 = 2, bank:$84 = 3);	//3f:f92f
$b6bb:
	$7e,7f = $7300,7301;
	a = #20;
	memcpy(src:$7e, dest:$80, len:$82 = 0, bank:$84 );	//$3f:f92f
	$7300 -= $7ecc;

	$91 = $7e89;
	for ($90 = 0;$90 != 8;$90++)
$b6dd:	{
		$91 <<= 1;
		if (carry) {	//bcc $b6e7
			presentEffectAtTarget();	//$33:b64f();
		} else {
$b6e7:			$7eb8 <<= 1;
		}
$b6ea:
	}
$b6f2:
}
```

________________________
# $33:b6f3 presentEffectAtTargetWorker

### code:
```js
{
	$c9++;		//doesPlaySound(1:play)
	$7e9c = 1;
	do {
$b6fa:
		presentEffectFrameAtTarget();	//$33:b711();
		$7e9c++;
	} while (($7e9c - 1) != $7300);
$b70b:
	fill_A0hBytes_f0_at$0200andSet$c8_0();	//$33:a05e();
	return call_waitNmi();	//$3f:f8b0();
}
```

________________________
# $33:b711 presentEffectFrameAtTarget

### args:
+	[in] u8 $7dd7[2][$90] : targetPosInfo
+	[in] u8 $7e8b : ? some flags
+	[in] u8 $7e9a :	play flag (#40 = play on player?)
+	[in] u8 $c0[4],$c4[4] : player pos {x,y}

### local variables:
+	u8 $8c : offsetX
+	u8 $8d : offsetY
+	u8 $7dd7[2] : x,y?

### code:
```js
{
	fill_A0hBytes_f0_at$0200andSet$c8_0();	//$33:a05e();
	loadAndBuildEffectSprites();	//$33:b7cf();
	a = $7e9a & #40;
	if (0 == a) { //bne $b74d;
		x = $90;
		$8c = a = $c0.x - #10;
		$8d = a = $c4.x - #0c;
		a = $7e8b & #20;
		if (0 != a) $8d -= #0c;	//beq $b73c
$b73c:
		a = $7e9d;
		if (5 != a) $8c -= 8;
	} else {
$b74d:
		x = a = $90 << 1;
		$8c = $7dd7.x - #18;	//連続しているが16bit値ではない(secが挟まってるので個別計算)
		$8d = $7dd8.x - #10;
	}
$b761:
	for (x = $c8,y = 0;y != #90;) {
$b765:	
		$0200.x = $8d + $7924.y;	//sprite.y?
		y++; x++;
		$0200.x = a = $7924.y;		//sprite.tileIndex?
		if (a == 0) $01ff.x = #f0;
$b77d:		y++; x++; $0200.x = $7924.y;	//sprite.attr?
$b785:		y++; x++; $0200.x = $7924.y + $8c;	//sprite.x?
		invertHorizontalIfBackAttack();	//$33:b19b();
		x++; y++;
	}
$b799:
	a = $7e9a & #40;
	if (a == 0) return setSpriteAndScrollx4();	//beq $b7a9
	
	swap60hBytesAt$0200and$02a0();	//$33:b7b5()
	setSpriteAndScrollx4();	//$b7a9
	return swap60hBytesAt$0200and$02a0();	//jmp $33:b7b5()
}
```

________________________
# $33:b7a9 setSpriteAndScrollx4

### code:
```js
{
	for ($b6 = 4;$b6 != 0;$b6--) {
$b7ad:		setSpriteAndScroll();	//$3f:f8c5();
	}
}
```

________________________
# $33:b7b5 swap60hBytesAt$0200and$02a0

### code:
```js
{
	for (x = 0;x != 0x60;x++) {
$b7b7:
		push (a = $02a0.x);
		$02a0.x = $0200.x;
		$0200.x = pop a;
	}
}
```

________________________
# $33:b7cf loadAndBuildEffectSprites

### args:
+	[in] u8 $7300[] : effectFrameParams (00-fe,ff:2byte escape)
+	[in] u8 $7e9c : frameParamOffset
+	[out] SpriteProperty $7924[]

### local variables:
+	u8 $87 : [000000ab] where
	-	a = (frameParam == #ff)
	-	b = (frameParam & #80)
+	SpriteTileParam $7900[0x24]
+	u16 $9708[ $7300[$7e9c] ]

### code:
```js
{
	$87 = 0;
	x = $7e9c;
	a = $7300.x;
	if (#ff == a) {	//bne b7e7
		$87 = 2;
		$7e9c++;
		a = $7301.x;
	}
$b7e7:
	$7e = a;
	$86 = a = a & #7f;
	rol $7e; rol $7e;
	$87 |= ($7e & 1);
	mul8x8_reg(a = $86,x = 2); //f8ea
	//ptrAddr = $00:9708+ (frameParam&#7f *2)
	memcpy(src:$7e = #9708 + (a,x),dest:$80 = #7900,len:$82 = 2,bank:$84 = 0); //f92f
	memcpy(src:$7e = $7900,dest:$80,len:$82 = #24,bank:$84);
$b82e:
	a = $7e9a & #40;
	if (a == 0) { //bne $b83c
		y = $87;
		$87 = $b7cb.y;
	}
$b83c:
	initAndTileEffectSprites(a = $87);	//$33:b8af(); 6x6
	x = 0;
	for (y = 0;y != #90;) { //90h : 24h * 4 =36 (6x6)
$b845:
		$7e = a = $7900.x;
		if (a >= 0) {	//bmi $b853
			setEffectSpriteTile();	//$33:b866();
			x++;
		} else {
$b853:
			x++;
			$80 = $7900.x;
			do {
				setEffectSpriteTile();	//$33:b866();
			} while( --$80 != 0 );
			x++;
		}
$b861:
	}
}
```

________________________
# $33:b866 setEffectSpriteTile

### args:
+	[in] u8 $7e : [xVHnnnnn]
+	[out] u8 $7925.y : sprite.tileIndex where
	-	$7e & #7f == 0 : 0
	-	otherwise : ($7e & #1f) + #49
+	[in,out] u8 $7926.y : sprite.attr
+	[in,out] u8 Y : spriteIndex

### local variables:
+	u8 $7f : [VH000011]

### code:
```js
{
	$7f = (($7e << 1) & #c0) | #03;
	a = $7e & #7f;
	if (a == 0) {	//bne b87c
		a = 0;
	} else {
$b87c:		a &= #1f; a += #49;
	}
$b881:
	$7925.y = a;	//tileIndex
	$18 = ($7f & 3) | $7926.y;
	$7926.y = ($7f & #c0) ^ $18;	//attr:パレット番号は必ず3?
	y += 4;
}
```

________________________
# $33:b8af initAndTileEffectSprites 

>tile6x6

### args:
+	[in] u8 A : coordinates mode (00:left top,01:right top,02:left bottom,03:right bottom)
+	[in] u8 $b89b.(a*4) : { beginX,diffX, beginY,dY }
+	[in] u8 $b8ab.(a) : defaultAttr

### code:
```js
{
	push (a);
	a <<= 2;
	for (x = 0,y = a;x != 4;x++,y++) {
$b8b5:		$7e.x = $b89b.y;
	}
	for (x = 0,y = 6;x != #90; x += 4) {
$b8c4:
		$7924.x = a = $80;	//sprite.y;
		if (--y == 0) {
			y = 6;
			$80 = a + $81;
		}
$b8d3:
	}
	$82 = a = $7e;
	for (x = 0;y = 6;x != #90; x += 4) {
$b8e3:
		$7927.x = a = $82;	//sprite.x;
		$82 = a + $7f;
		if (--y == 0) {
			y = 6;
			$82 = $7e;
		}
	}
$b8fe:
	y = pop a;
	a = $b8ab.y;
	for (x = 0;x != #90;x += 4) {
$b905:		$7926.x = a;		//sprite.attr
	}
}
```

________________________
# $33:b91a 

### code:
```js
{
	$7ecc = 0;
	return $33:b937();
}
```

________________________
# $33:b937 

### code:
```js
{
	beginActionEffect();	//$33:b09b();	cast effect	[$7e8b,$7e8c]
	$33:b276();	//launch	
	blowEffect_end();	//$33:ac35();	//?
	return presentActionEffect();	//$33:b68d();
}
```

________________________
# $33:bafd effect_0d

### args:
+	[in] u8 $7e9d : from actionParam[6]

### code:
```js
{
	y = $7e9d << 1;
	$7e,7f = $bc2b.y, $bc2c.y;
	callPtrOn$007e();	//$32:bb15();
	fill_A0hBytes_f0_at$0200();	//$32:a42b();
	setSpriteAndScroll();	//jmp $3f:f8c5
}
```

________________________
# $33:bb15 callPtrOn$007e 

### code:
```js
{
	(*$007e)();
}
```

________________________
# $33:bd45 updateCharacterPos

### args:
+	[in] u8 x : charIndex
+	[in] $7d7d,7cf4
+	[in] $7d7f[4] : goal coords
+	[out] $c0[4],$c4[4] = {x,y}

### code:
```js
{
	if ((a = $7d7d) == 0) {
		$7e = 0;
		$7f = #ff;
	} else {
$bd55
		$7e = 1;
		$7f = #80;
	}
$bd5d
	if ($c0.x== $7d7f.x) 
$bd64		return;
$bd65:
	y = x << 1;
	a = $7d9b.y & 5;
	if (a == 0) $bdbd
$bd6f:	if (0 == (a & 4)) $bd94
$bd73:	//a == 5 or 4
	y = $7cf4 & 7
	$c4.x += $bde9.y;
	$7d83.x = $bdf1.y | $7f;
	$c0.x += ($7e + $7e);
	return;
$bd94:	//$7d9b.y == 1
	$7d83.x = (($7cf4 & 4) >> 2) + #0a;
	if (0 == (a = $7dc1.x)) bdb5;
bda6:
	a = $7d9b.y & 8;
	if (0 == a) bdb5;
	$7d83 ^= #80;
bdb5:
	$c0 += $7e;
bdbc:	
	return;
$bdbd:	//$7d9b.y & 5 == 0
	$7d83.x = (($7cf4 & 4) >> 2) + 1;
	if ($7dc1.x != 0) $bdde
	a = $7d9b.y & 8;
	if (a == 0) $bdde
	$7d83.x ^= #80
$bdde:
	$c0.x += ($7e + $7e);
	return;
}
```

________________________
# $33:be89 

### code:
```js
{
	for (x = 0;x != 4;x++) {
		updateCharacterPos();	//$33:bd45
	}
	$32:90d8
	$7cf4++;
	return;
}
```

________________________
# $33:be9a moveCharacter	

>effect_14

### args:
+	[in] u8 $7d7f[4] : goalX

### code:
```js
{
	$33:be89
	loadCharacter();	//$32:9f11 = effect_03 = call_2e_9d53(#13)
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5
	for (x = 0;x != 4;x++) {
		a = $c0.x;
		if (a != $7d7f.x) $be9a;
	}
	return;
$beb2
}
```

________________________
# $33:bf1e loadEffectSpritesWorker_base0

### code:
```js
{
	$7e,7f = x = 0;
}
```
________________________
# $33:bf24 loadEffectSpritesWorker

### code:
```js
{
	mul8x8_reg(a,x = 6);	//f8ea
	$18,19 = #beb2 + a,x;
	push (a = y);
	
	y = 0;
	$7e,7f += $18[y++],$18[y++];
	$80,81 = $18[y++],$18[y++];
	$82 = $18[y++];
	$84 = $18[y++];
	copyToVramDirect(src:$7e, vramAddr:$80, len:$82, bank:$84)	//$3f:f969();
	y = pop a;
}
```