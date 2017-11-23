________________________________________________________________________________
# $3a:8533 getBattleFieldId
<details>

### args:
+	`[in] u8 $48 : warpId`

### (pseudo)code:
```js
{
	call_switch2ndBank(per8k:a = #39); //ff09
	x = $48;
	if ( $78 != 0) { //beq 8546
$853e:
		$6b = $53 = $bd00.x;
		return;
	}
$8546:
	$6b = $53 = $bc00.x;
	return;
$854e:
}
```
</details>

________________________________________________________________________________
# $3a:8f43 field::loadTileParams
<details>

### args:
+	[out] u8 $0500[64],0580[64],0600[64],0680[64] : 
	static tile indices (shared by all maps)`
+	[out] u8 $0700[64] :
	palette ids for static tiles?
+	[out] u8 $0540[64],05c0[64],0640[64],06c0[64] : 
	dynamic tile indices (indiviual to each maps,also updated dynamically)
+	[out] u8 $0740[64] :
+	[out] TileEvent $0400[128]

### (pseudo)code:
```js
{
	call_switch2ndBank(per8k:a = #00); //ff09
	for (x = #3f;x >= 0;x--) {
		$0500.x = $a000.x;
		$0580.x = $a040.x;
		$0600.x = $a080.x;
		$0680.x = $a0c0.x;
		$0700.x = $a400.x;
	}
$8f6b:
	$80,81 = #a100 + ($78 >> 1);
	for (y = 0;y < #40;y++) {
		$0540.y = $80[y];	//0540-057f
	}
$8f83:
	for (y;y < #80;y++) {
		$0580.y = $80[y];	//05c0-05ff
	}
$8f89:
	for (y;y < #c0;y++) {
		$05c0.y = $80[y];	//0640-067f
	}
$8f97:
	for (y;y != 0;y++) {
		$0600.y = $80[y];	//06c0-06ff
	}
$8f9f:
	$80,81 = #a440 + (($78 & #06) << 5);
	for (y = #3f;y >= 0;y--) {
		$0740.y = $80[y];
	}
$8fbb:
	$80,81 = #a500 + ($78 >> 1);
	do {
		$0400.y = $80[y];	//$80: ($00:a500 + ($78 >> 1)) [00500]
	} while (++y != 0);
$8fd7:
	return;
}
```
</details>

________________________________________________________________________________
# $3a:9091 getPaletteEntriesForWorld
<details>

### args:
+	[in] u8 $78 : world
+	u8 $00:b640[0x10] : paletteEntries for background

### notes:
フロアマップでも呼ばれる

### (pseudo)code:
```js
{
	y = ($78 & #06) << 3;
	for (x = 0;x < #10;x++) {
		$03c0.x = $b640.y;
	}
	y = ($78 & #04) << 2;
	for (x = 0;x < #10;x++) {
		$03d0.x = $b670.y;
	}
	//....
}
```
</details>

________________________________________________________________________________
# $3a:910b getPaletteEntriesForFloor
<details>

### args:
+	[in] WarpParam $0780

### (pseudo)code:
```js
{
	getPaletteEntries(offset:x = 1, paletteId:y = $0785);
	getPaletteEntries(offset:x = 5, paletteId:y = $0786);
	getPaletteEntries(offset:x = 9, paletteId:y = $0787);
	getPaletteEntries(offset:x = #19, paletteId:y = $0788);
	getPaletteEntries(offset:x = #1d, paletteId:y = $0789);
	$03cd = 0;
	$03ce = 2;
	$03cf = #30;
	$03d0 = $03c0 = #0f;
	return;
$914b:
}
```
</details>

________________________________________________________________________________
# $3a:914b getPaletteEntries
<details>

### args:
+	[in] x : dest offset
+	[in] y : paletteId
+	$00:b100[3][0x100] : colorIds

### (pseudo)code:
```js
{
	$03c0.x = $b100.y;
	$03c1.x = $b200.y;
	$03c2.x = $b300.y;
	return;
}
```
</details>

________________________________________________________________________________
# $3a:915e
<details>

### args:
+	[in] u8 $48 : warpId
+	u8 $02:a000[0x10][0x100]

### (pseudo)code:
```js
{
	call_switch2ndBank(per8k:a = #02);	//ff09
	$80,81 = #a000 | ($48 << 4);
	y = #0f;
	if ($78 != 0) { //beq 9182
$917b:
		$81 += #10;
	}
$9182:
	for (y;y >= 0;y--) {
		$0780.y = $80[y];
	}
	floor::init();	//$9267();
$918d:
	a = 0;
	for (x = #3f;x >= 0;x--) {
		$0740 = a;
	}
$9197:
	y = 0;
	$80,81 = #7400;

	for ($80,81; $80,81 <= #7800; $80,81++) {
$91a0:
		a = $80[y = 0];
		if (a < #60) 91bb;
		elif (a < #64) 91b4;
		elif (a < #70) 91bb;
		elif (a >= #7d) 91bb;
$91b4:
		//60 <= a < 64 || 70 <= a < 7d
		floor::getDynamicChip();	//$91c8();
		$80[y = 0] = a;
$91bb:
	}
	return;
$91c8:
}
```
</details>

________________________________________________________________________________
# $3a:91c8 floor::getDynamicChip
<details>

### args:
+	[in,out] a : chipId
+	[out] $0500[ allocatedChipId ] : serial number 
+	$921f(7521f) : チップ分類

		00 00 00 00 04 04 04 04  04 04 04 04 04 04 04 04
		01 01 01 01 01 01 01 01  02 02 02 02 04 04 04 04
+	$923f: チップに割り当てるIDのベース値
		(割り当てるのはベース+同IDチップ内における順番)

		f0 f4 f8 fc 00 00 00 00  00 00 00 00 00 00 00 00
		80 90 a0 b0 c0 c4 c8 cc  e0 e4 e8 ec d0 00 00 00

### (pseudo)code:
```js
{
	x = a - #60;
	$88 = $0740.x; $0740.x++; //特定IDのチップの数
	y = $921f.x;
	$89 = $0760.y;	//特定の分類のチップの数
	$0760.y += 1;
	y = $923f.x + $88;
	if (x != #1c) {//beq 91f7
$91ed:
		$0500.y |= $89;	//y:allocated chipId => $89:serial number of chip that belongs to same category
		a = y;
		return;
	}
$91f7:
	push (a = y);
	x = $89;
	push (a = $0710.x);	//treasureId (0x000-1FF) 
	x = a & 7;
	y = pop a >> 3;
	if ( $78 != 0) { //beq 9210
		//下の世界
		y += #20;
	}
$9210:
	temp = ($925f.x & $6040.y);	//925f: 01 02 04 08 10 20 40 80
	y = pop a;	//= 923f.(chipId - #60) + $0740.(chipId - #60)
	if (temp >= 1) $91ed;
$921c:
	a = #7d;	//空箱
	return;
$921f:
}
```
</details>

________________________________________________________________________________
# $3a:9267 floor::init
<details>

### args:
+	ChipDef $01:a380(2380)[?][4][128]
+	ChipToPalette $01:b100(03100)[8][128]
+	ChipAttributes $01:b500(03500)[8][128] : chipAttributeTable { attributes, event }

### (pseudo)code:
```js
{
	call_switch2ndBank(per8k:a = #01);	//ff09
	x = ($0780 >> 5) & 7;
	$80,81 = #a380 + (x << 9);
	$82,83 = #b100 + ((x + 1) << 7);
	$84,85 = #b500 + (x << 8);
$929a:
	x = 0;y = 0;
	do {
$929e:
		$0400.x = $84[y];
		$0500.x = $84[++y];
		x++;
	} while (++y != 0);
$92ad:
	for (y;y < #80;y++) { //bpl
		$0600.y = $82[y];
	}
$92b5:
	for (y = 0;y < #80;y++) { //bpl
		$7c00.y = $80[y];
	}
	for (y;y != 0;y++) { //bne
		$7c80.y = $80[y];	//7d00-7d7f
	}
$92c7:
	$81++;
	for (y;y < #80;y++) { //bpl
		$7e00.y = $80[y];
	}
	for (y;y != 0;y++) { //bne
		$7180.y = $80[y];	//7200-727f
	}
$92d9:
	for (y = 0;y < #80;y++) { //bpl
$92db:
		x = $93c1.y;
		$0480.y = $0400.x;	//attribute
		$0580.y = $0500.x;	//event
		$0680.y = $0600.x;	//palette
		$7c80.y = $7c00.x;	//upper left tile
		$7d80.y = $7d00.x;	//upper right tile
		$7e80.y = $7e00.x;	//lower left tile
		$7280.y = $7200.x;	//lower right tile
	}
$930b:
	$49 = $0781 & #20;	//$0781: warpparam.+01
	$6d = ($0781 & #80) | #0d;
	$6e = ($0781 & #40) << 1) | #0e;
	if ($aa == 0) { //bne 9341
$9329:
		$29 = ($0780 & #1f) - 7) & #3f;	//left?
		$2a = ($0781 & #1f) - 7) & #3f;	//top?
	}
$9341:
	$4b = $0782;
	$4c = $0783;
	$4d = $078a;
	$0730 = $078b;
	$80 = $078c;
	$81 = $078d | #20;

	call_switch2ndBank(per8k:a = #10);
$9368:
	x = $078e << 1;
	if (!carry) { // bcs 937e
		$82 = $a000.x;
		$83 = $a001.x | #20;
		//jmp 938a
	} else {
$937e:
		$82 = $a100.x;
		$83 = $a101.x | #20;
	}
$938a:
	x = $078f << 1;
	if (!carry) { //bcs 93a0
		$84 = $a200.x; $85 = $a201.x | #20;
	} else {
		$84 = $a300.x; $85 = $a301.x | #20;
	}
$93ac:
	for (y = #0f;y >= 0;y--) {
		$0700.y = $80[y];	//warp points
		$0710.y = $82[y];	//treasures
		$0720.y = $84[y];
	}
	return;
$93c1:
}
```
</details>

________________________________________________________________________________
# $3b:a000 floor::call_dispatchObjectEvent {
<details>

```js
{
	return $a067();
}
```
</details>

________________________________________________________________________________
# $3b:a067
<details>

### (pseudo)code:
```js
{
	$24 = $25 = $23 = $22 = $20 = 0;
	return floor::object::dispatchEvent(); //a12b
}
```
</details>

________________________________________________________________________________
# $3b:a12b floor::object::dispatchEvent
<details>

### args:
+	[in] u8 $70 : eventId

### (pseudo)code:
```js
{
	a = $70;
	if (a < #c0) return floor::object::processEventUnderC0(); //$acd1();
$a134:	if (a >= #d0) return floor::object::invokeEventAboveD0(); //$b53f();
$a13b:	a = $70 & #0f;
	if (a < 4) {
		$20 = $a1ca.(x = a);
		return;
	}
$a14a:
	if (a < 8) {
		$33 = $a1ca.(x = a & 3);
		return;
	}
$a157:
	switch (a) {
	case 8: $7e &= #7f; return;
$a162:	case 9: $7e |= #80; return;
$a16d:	case #0a: $42 = $46 = 6; return; //ノーチラス
$a178:	case #0b: $42 = $46 = 7; return; //invincible
$a183:	case #0c: $7e &= #bf; return;
$a18e:	case #0d: $7e |= #40; return;
$a199:	case #0e:
		$42 = $46 = 0; //get off (walk) ?
		$6007 = $78; //world
		$6005 = $27 + #07;
		$6006 = $28 + #07;
		$6004 = 1;
		return;
$a1be:	case #0f: $42 = $46 = 1; return;	//ride on chocobo?
	}
$a1c9:
	return;
}
```
</details>

________________________________________________________________________________
# $3b:acd1 floor::object::processEventUnderC0
<details>

### args:
+	[in] u8 $70 : [iiiieeee] i:object index e:object event id
+	[out] u8 $17 :

### (pseudo)code:
```js
{
	a = $700c.(x = $70 & #f0);
	if (a != 0) {
$acce:
		$17++; return;
	}
$acdb:
	a = ($70 & #0f);
	if (a < 4) { //bcs acf7
		$84 = $7002.x;	//object.x
		$85 = $7003.x;	//object.y
		$86 = $7106.x;	//object2.layer
		a = $70;
		return $afdd();
	}
$acf7:
	if (a < 8) { //bcs ad0c
		y = (a & 3) << 1;
		$700e.x = $ad55.y;	//object.pBuilder
		$700f.x = $ad56.y;
		return;
	}
$ad0c:
	switch (a) {
	case 8: $7000.x = $700a.x; return;	//object.scriptId
	case 9: $7000.x = 0; return;
	case #0a: a = 1; return $ab71();
	case #0b: a = 0; return $ab71();
	case #0c: $7001.x |= #40;	//object.attr
	case #0d: $7001.x &= #b0;
	case #0e: return $ac68();
	default: return $ac25();
	}
}
```
</details>

________________________________________________________________________________
# $3b:aead
<details>

### args:
+	[in] ptr $80 : $700e.x,$700f.x + 0|8

### (pseudo)code:
```js
{
	$80,81 += $7105.x;
	$c01e(); //call_da3a
}
```
</details>

________________________________________________________________________________
# $3b:b0c5 getChipIdAtObject
<details>

### args:
+	[in] u8 $4c : default chip id? (warpparam.+03 = $0783)
+	[in] u8 $84 : object.x?
+	[in] u8 $85 : object.y?
+	[in] mapdata $7400[0x20*0x20]
+	[in] chipattr $0400[0x100]

### (pseudo)code:
```js
{
	y = $4c;
	a = ($84 | $85) & #20;
	if (a == 0) { //bne b0eb
		//マップの範囲内なので座標にあるチップIDをマップデータから取得
		$80,81 = (($85 << 5) + #7400 | $84);
		$67 = y = $80[y = 0];
	}
$b0eb:
	a = $0400.y;
	if (a < 0) {
$b106:		sec; return;
	}
	a &= 7;
	if ( (a & #07) == 0) {
$b108:
		$86 = 0; clc; return;
	}
	if ( a >= #04 
		|| ( (a != #03) && ((a |= $86) != #03) ) )
	{
$b104:
		clc; return;
	}
$b106:
	sec; return;
}
```
</details>

________________________________________________________________________________
# $3b:b17c floor::object:
<details>

### (pseudo)code:
```js
{
	if ($700d.x != 0) //bne b188
	 	||  (($7102.x & $f0) == 0) //bne b1cd
	{
$b188:
		if ((a = $7008.x) != 0) { //beq b1ac
$b18d:
			a = $7006.x = (a + $7006.x) & #0f;
			if (a == 0) { //bne b1cd
$b198:
				$7008.x = $700c.x = $700d.x = 0;
				$7004.x = $7002.x;
			}
		} 
$b1ac:		else if ((a = $7009.x) != 0) { //beq b1cd
			$7007.x = (a + $7007.x) & #0f;
			if (a == 0) { //bne b1cd
				$7009.x = $700c.x = $700d.x = 0;
				$7005.x = $7003.x;
			}
		}
	}
$b1cd:
	a = $7006.x | $7007.x;
	if (a == #08) { //bne b1ee
$b1d7:
		if (($7100.x & #04) != 0)  //beq b1e8
			&& ($7106 & #01) != 0)) //lsr bcc b1e8
		{
$b1e4:
			a = 0;
			//beq b1eb
		} else {
$b1e8:
			a = $7100.x;
		}
		$7101.x = a;
	}
$b1ee:
	$80 = ($7007.x - $36) & #0f;
	a = ($7005.x - $2a) & #3f;
	if (a < #10) { //bcs b230
$b203:
		a = (a << 4) | $80;
		if (a < #e8) { //bcs b230
			$41 = a - 2;
			$80 = ($7006.x - $35) & #0f;
			a = ($7004.x - $29) & #3f;
			if (a < #10) { //bcs b230
$b224:
				a = (a << 4) | $80;
				if (a < #f8) $b232(); //bcc b232
			}
		}
	}
$b230:
	sec; return;
$b232:
	$40 = a;
	$8f = x;
	if ($700d.x >= 0) { //bpl b23e jmp b2c6
$b23e:
		a = $7001.x & #f0;
		if (a == 0) { //beq b275
			a = (($7006.x | $7007.x) << 1) & #08;
		} else if (a < #80 && a >= #40) { //asl bcc b251 asl bcs b262
$b262:
			$00 = a = $f0;
			a &= #08; //jmp b27e
		} else if (a < #c0) { //asl bcc b254
			a = 0;	//beq b27e
		} else if (a < #f0) { //asl asl bcc b258
			$00 = a = ($f0 >> 1);
			a &= #08; //beq b27e
		} else { //bcs b26b
			$00 = a = ($f0 << 1);
			a &= #08; //jmp b27e
		}
$b27e:
		push a;
		$80,81 = a + ($700e.x,$700f.x);
		$82 = x + #20;
		if (($7001.x & #40) != 0 //beq b2ad
			&& ($7001.x & #10) != 0 //beq b2ad
			&& ($00 & #10) != 0) //beq b2ad
		{
$b2a6:
			$82 -= #08;
		}
$b2ad:
		pop a;
		if ( (a != 0)  //beq b2c3
			&& ($7001.x & #f0) == 0) //bne b2c3
		{
			if ($7007.x != 0) { //beq b2c1
				$40--;
			} else {
$b2c1:
				$41--;
			}
		}
$b2c3:
		return $aead();
	}
$b2c6:
	//....
}
```
</details>

________________________________________________________________________________
# $3b:b2fd floor::loadObjects
<details>

+	ptr $2c:8000[0x100] : index = $0784 (warpparam.+04)

### (pseudo)code:
```js
{
	do {
		$7000.x = 0;
	} while (++x != 0);
	call_switch1stBank(per8k:a = #2c);	//ff06
	$80,81 = #8000 + ($0784 << 1);
	$8c,8d = #8000 | ($80[y],$80[++y]);
	$8a,8b = #7100;
	$8e,8f = #7000;
$b336:
	while ($8c[y = 0] != 0) { //beq b34d
		floor::loadObject();	//$b34e();
		$8c,8d += 4;
	}
$b34d:
	return;
}
```
</details>

________________________________________________________________________________
# $3b:b34e floor::loadObject
<details>

### args:
+	[in] u8 $78 : world
+	[in] u8 a : objectId? (= $8c[0] )
+	[in,out] ptr $8a : ? ( = #7100) [out] += #10
+	[in] ObjectParam* $8c : from $2c:8000 + [ $2c:8000[ $0784] ]
+	[in,out] RuntimeObject* $8e : ( = #7000) [out] += #10
+	$01:9e00[0x200] : [aaaabbbb] a:? ->$7103 b:? ->$7102

### (pseudo)code:
```js
{
	y = $8e[y = #0a] = a;
	getObjectFlag();	//$b51a();
	if (!equal) { //beq b359
		a = y;
	}
$b359:
	$8e[y = 0] = a; //フラグ($6080-)がクリアされていたら0,otherwise =objectid
	$84 = $8e[y = 2] = $8e[y = 4] = $8c[y = 1]; //1:++y
	$85 = $8e[y = 3] = $8e[y = 5] = $8c[y = 2];
	a = $86 = $8c[y = 3];
	$8e[y = 1] = a & #f0;
$b380:	$8e[y = 6,7,8,9] = a = 0;
$b38f:	$8e[y = #0b,#0c,#0d,#0e] = 0;
$b399:
	y = #0f;
	getObjectBuilderAddress(); //$b3f8();
	$8e[y] = a;
	$8e[--y] = x;
	a = ($86 << 4) & #c0;
	$8a[y = #05] = a; //7105+offs
	getChipIdAtObject();	//$b0c5(); [out] y = chipId
$b3b3:
	$8a[y = 0] = a = $0400.y & #37;
	$8a[++y] = a;
	$8a[y = #06] = a & #03;
	call_switch1stBank(per8k:a = #01); //ff06
	y = $8e[y = #0a];
	a = $9e00.y;
	if ( (x = $78) != 0) { //beq b3d9
		a = $9f00.y;
	}
$b3d9:
	push a;
	$7102.(y = $8e) = a & #0f; //$8e = index*0x10
	$7103.y = (pop a) >> 4;
	call_switch1stBank(per8k:a = #2c); //ff06
	$8a = $8e = $8e + #10;
	return;
$b3f8:
}
```
</details>

________________________________________________________________________________
# $3b:b3f8 getObjectBuilderAddress
<details>

### args:
+	[in] u8 $86 : = ObjectParam.+03
+	[out] a,x = 
	+	$86 == 0 : #b43a
	+	$86 == 1 : #b44a
	+	$86 == 2 : #b42a
	+	$86 == 3 : #b41a

### (pseudo)code:
```js
{
	switch ( $86 & #03) {
	case 0: //beq b410
		a = #b4; x = #3a; return;
	case 1: //cmp #01 beq b415
$b415:
		a = #b4, x = #4a; return;
	case 2: //cmp #02 beq b40b
$b40b:
		a = #b4; x = #2a; return;
	default:
$b406:
		a = #b4; x = #1a; return;
	}
}
```
</details>

________________________________________________________________________________
# $3b:b51a getObjectFlag
<details>

### args:
+	[in] u8 a : objectId?
+	[in] u8 $78 : world
+	[in] $6080[2][0x20] : flags (1bit per id)

### (pseudo)code:
```js
{
	$80 = a;
	x = a & 7;
	$81 = $b537.x;
	a = $80 >> 3;
	if ((x = $78) != 0) { //beq b530
		a += #20;
	}
$b530:
	a = $6080.(x = a) & $81;
	return;
$b537:
	01 02 04 08 10 20 40 80
}
```
</details>

________________________________________________________________________________
# $3b:b53f floor::object::invokeEventAboveD0
<details>

### args:
+	[in] u8 a : event (d0-ff)

### (pseudo)code:
```js
{
	if (a >= #e4) { //bcc b555
		x = (a - #e4) << 1;
		$80,81 = $b617.x,$b618.x;
		return (*$80)(); //funcptr
	}
$b555:
	x = (a - #d0) << 1;
	$80,81 = $b567.x,$b568.x
	return (*$80)();
$b567: //77567
	8F B5  97 B5  9F B5  A3 B5
	A7 B5  AA B5  AD B5  B2 B5
	B7 B5  BA B5  D7 B5  DA B5
	DF B5  E4 B5  EF B5  FC B5
	4F B6  68 B6  6F B6  72 B6
$b617: //77617
	72 B6  72 B6  72 B6  73 B6
	8E B6  94 B6  9A B6  9D B6
	A0 B6  A3 B6  A6 B6  B4 B6
	BF B6  D5 B6  E0 B6  E5 B6
	EA B6  EF B6  F4 B6  0F B7
	1C B7  50 B7  5E B7  6C B7
	75 B7  9D B7  A2 B7  A3 B7
}
```
</details>

________________________________________________________________________________
# $3b:b6bf floor::object::event::F0
<details>

### args:
+	[out] ptr $94 : string ptr
+	[out] u8 $76 : string Id

### (pseudo)code:
```js
{
	$76 = $0740.(x = $71);
	a = #84;
	if ((x = $78) != 0) { //beq b6ce
		a = #86;
	}
$b6ce:
	$95 = a;
	$94 = 0;
	return;
}
```
</details>

________________________________________________________________________________
# $3b:bec6 drawNextLineVertical
<details>

### (pseudo)code:
```js
{
	$82 = #f - $30;
	y = 0;
	a = $2002;
	$2006 = $81;
	$2006 = $80;
	$2000 = #04;
	for (y; y < $82;y++) {
		$2007 = $0780.y;
		$2007 = $07a0.y;
	} //bcc bee1
$bef2:
	if (y < #f) { //bcs bf15
		$2006 = $81 & #24;
		$2006 = $80 & #1f;
		for (y;y < #f;y++) {
$bf04:
			$2007 = $0780.y;
			$2007 = $07a0.y;
		}
	}
$bf15:
	y = 0;
	$2006 = $81;
	$2006 = $80 + 1;
	for (y; y < $82;y++) {
		$2007 = $0790.y;
		$2006 = $07b0.y;
	}
$bf35:
	if (y < #0f) { //bcs bf5b
		$2006 = $81 & #24;
		$2006 = ($80 + 1) & #1f;
		for (y;y < #0f;y++) {
$bf4a:
			$2006 = $0790.y;
			$2006 = $07b0.y;
		}
	}
$bf5b:
	$2000 = #88;	//nmi on vblank | sprite addr $1000
	return;
$bf61:
}
```
</details>

________________________________________________________________________________
# $3c:91a3 fieldMenu::updateCursorPos
<details>

### args:
+	[in] u8 a : cursorIncrement
+	[in,out] u8 $78f0 : cursor
+	[in] u8 $78f1 : rowSize

### (pseudo)code:
```js
{
	$06 = a;
	$9175();
	$80 = a & #f;
	if (a == 0) return;	//beq 91c8
	if (a < 4) { //bcs 91b6
$91b2:
		$06 = x = 4;
	}
$91b6:
	if ((a & 5) == 0) { //bne 91c9
$91ba:
		a = $78f0 - $06;
		if (a < 0) { //bcs 91c5
			a += $78f1;
		}
$91c5:
		$78f0 = a;
		return;
	}
$91c9:
	a = $78f0 + $06;
	if (a < $78f1) $91c5;
	a -= $78f1;
	if (a >= 0) $91c5;
$91d9:
}
```
</details>

________________________________________________________________________________
# $3c:92f3 floor::copyEventScriptStream
<details>

### (pseudo)code:
```js
{
	x = 0;
$92f5:
	while ($7b00.x != #ff)
	{
		while (	$7b00.(++x) != #ff) {}
		x+=2;
	}
$9309:
	x += 2;
	for (y = 0;y < #20;x++,y++) {
		$0740.y = $7b00.x;
	}
$9319:
	x = 0;
$931b:
	if ((a = $7b00.x) == #ff) { //bne 9328
		$6c = $7b01.x;
		return;
	}
$9328:
	if (a < 0) { //bpl 9332
		x++;
		getEventFlag();	//$9344();
		if (!equal) $931b;
		//beq 9338
	} else {
$9332:
		x++;
		getEventFlag(); //$9344
		if (equal) $931b;
	}
$9338:
	while ($7b00.x != #ff) { x++; } //bne 9338
	x++;
	return $931b;
}
```
</details>

________________________________________________________________________________
# $3c:9344 getEventFlag?
<details>

### (pseudo)code:
```js
{
	push (a & #7f);
	y = a & 7;
	$80 = $935a.y;
	y = pop a >> 3;
	a = $80 & $6020.y;
	return;
$935a:
	01 02 04 08 10 20 40 80
}
```
</details>

________________________________________________________________________________
# $3c:937e floor::searchSpaceForItem
<details>

### args:
+	[in] u8 $80 : itemid
+	[out] bool carry : item full
+	[out] u8 x : index

### (pseudo)code:
```js
{
	for (x = 0;x < 0x20;x++) {
$9380:
		if ( $60c0.x == $80) goto $9399;
	}
$938c:
	for (x = 0;x < 0x20;x++) {
$938e:
		if ( $60c0.x == 0) goto $9399;
	}
	//here carry is set
	return;
$9399:
	clc;
	return;
}
```
</details>

________________________________________________________________________________
# $3c:961c {
<details>

```js
{
	$8f74();
	$78f0 = #14;
	x = $7f | #0f
	$d10b();
	return $a685;
}
```
</details>

________________________________________________________________________________
# $3c:962f jobMenu::main
<details>

### args:
+	[in] u8 $7f,x : character offset

### (pseudo)code:
```js
{
	$96ba();
	$9592();
	$a685();
	$956f();
	jobMenu::getCosts();	//$ad85();
$963e:
	$a3 = $78f0 = 0;
	
	field::drawWindowOf(x = #0c );	//aaf1
	field::loadAndDrawString(a = #48 );	//$a87a

	field::drawWindowOf(x = #0d );
	$a878(a = #49 );

	field::drawWindowOf(x = #0e );
$965e:
	do {
		do {
			$aaa6(x = #0e);
			field::loadAndDrawString(a = #4a );	//$a87a
$9668:
			do {
				$a2 = 1;
				$a7cd();

				fieldMenu_updateCursorPos(incr:a = 8);	//$91a3();
				$9698();
				if ($25 != 0) return $961c(); //bne 961c
$967b:
			} while ($24 == 0); //beq 9668
$967f:
			$8f74();
			$96a5();
		} while (!carry); //bcc 965e
$9687:
		a = #70;
		$96da();
	} while (($20 & #80) == 0); //beq 965e
$9692:
	$ab8f();
	return $961c();	//jmp
}
```
</details>

________________________________________________________________________________
# $3d:a52f fieldMenu::main
<details>

### (pseudo)code:
```js
{
	$78f0 = 0;
	$25 = 0;
	$2001 = 0;
	$79f0 = $7af0 = 0;
	
	$dd06();
	$f7bb();
	$c486();
	$ff00();
	$4014 = 2;
	$d308();
$a555:
	$fd = $ff = #88;
	$959f();
	$7f49 = #ff;
	$57 = #3c;
$a567:
	$9599();
	$37 = 1;
$a56e:
	$a3 = $a4 = $b4 = x = 0;
	a = #30;
	$a666();
	x = 1; a = #31;
	$a666();
	x = 2; a = #32;
	$a666();
	x = 3; a = #33;
	$a666();
	x = 4; a = #34;
	$a666();
$a597:
	$a2 = 1;
	a = $2d >> 1;	
	if (carry) { //bcc a5a9
$a5a0:
		//(($2d & 1) == 1) : セーブ不可
		$78f1 -= 4; 
	}
$a5a9:
	do {
		$a7cd();
		a = 0;
		$8000();
		a = 0;
		$80cb();

		fieldMenu_updateCursorPos(incr:a = 4);	//$91a3();
$a5bb:
		if ($25 != 0) goto $a646; //beq a5c2
$a5c2:
	} while ($24 != 0) //beq a5a9
$a5c6:
	//$78f0: cursor pos (4/row)
	$8f74();
	$a654();
	if ((a = $78f0) == 0) { //bne a5d7
$a5d1:	//アイテム
		$9ec2();
		goto $a567;
	}
$a5d7:
	if (a == 4) { //bne a5ef
	//まほう
		selectCharacter();	//$a6b4();
		if (carry) goto $a5a9; //bcs
		x = $7f;
		a = $6102.x & #c0;	//status
		if (a == 0) { //bne a622
			$9761();
			goto $a567;
		}
	} 
$a5ef:	
	else if (a == 8) { //bne $a5fe
	//そうび
		selectCharacter();	//$a6b4();
		if (carry) $a5a9; //bcs
		$9bb5();
		goto $a567;
	}
$a5fe:
	else if (a == #c) { //bne $a60d
$a602:	//ステータス
		selectCharacter();	//$a6b4();
		if (carry) $a5a9;
		$a83b();
		goto $a567;
	}
$a60d:
	else if (a == #10) { //bne $a617
	//ならびかえ
		$a696();
		goto $a5a9;
	}
$a617:
	else if (a == #14) { //bne $a640
$a61b:	//ジョブ
		if ( ($6021 & #1f) == 0) { //bne a62c
$a622:		//まほう→死亡or石化もここにくる
			$d529();
			$a3 = 0;
			goto $a5a9;
		}
$a62c:
		selectCharacter();	//$a6b4();
		if (carry) $a5a9;
		x = $7f;	//7f=char offset
		if (($6102.x & #c0) != 0) $a622; //bne $a622
$a63a:
		jobMenu_entry();	//$962f();
		goto $a534;
	}
$a640:
	$a897();
	goto $a567;
$a646:
	//OnB (closeMenu)
	$a685();
	$2001 = 0;
	$a654();
	return $8f58();
}
```
</details>

________________________________________________________________________________
# $3d:a666
<details>

### (pseudo)code:
```js
{
	
}
```
</details>

**fall through**
________________________________________________________________________________
# $3d:a66b
<details>

### (pseudo)code:
```js
{
	$92 = a;
	$94,95 = #8200
	return $ee65();
}
```
</details>

________________________________________________________________________________
# $3d:a6b4 fieldMenu::selectCharacter
<details>

### args:

####	out:
+	bool carry : canceled
+	u8 $7f : offset of selected character

### (pseudo)code:
```js
{
	//...
}
```
</details>

________________________________________________________________________________
# $3d:a87a field::loadAndDrawString
<details>

### (pseudo)code:
```js
{
	field::loadString();	//$d1b1();
	$93 = #18;
	$3e = 1;
	$3f = #7b;
	return field::drawEncodedStringInWindowAndRestoreBanks();	//$eb61();
}
```
</details>

________________________________________________________________________________
# $3d:a88c saveMenu::close
<details>

### (pseudo)code:
```js
{
	$8f74();
	$78f0 = #18;
	return $a685();
}
```
</details>

________________________________________________________________________________
# $3d:a897 fieldMenu::OnSaveSelected
<details>

### notes:
$24:a $25:b

### (pseudo)code:
```js
{
	//...
$a8e3:
	$79f0 = 0;
	$a984();
$a8eb:
	do {
		$a7cd();	//cursor?
		a = ($79f0 >> 2) & 3;
		$8241();
		a = 4;
		$91d9();
		if ($25 != 0) $a88c;	//b
	} while ($24 == 0); //beq a8eb:
$a905:
	$8f74();
	a = #4c;
	$a996();
	$a2 = 1;
	$78f0 = 0;
$a916:
	do {
		$a7cd();
		a = ($79f0 >> 2) & 3;
		$8241();

		fieldMenu::updateCursorPos(incr:a = 4);	//$91a3();
		if ($25 != 0) $a935; //b
	} while ($24 == 0); //beq $a916
$a930:
	if ($78f0 != 0) goto $a88c; //beq a938 まえのデーターをけします  rｧいいえ
$a938:
	//rｧはい
	a = #4d;
	$a996();
	
	a = $7f3a + 1;
	if (a >= 100) { //bcc a949
		a = 1;
	}
$a949:
	$7f3a = a;
	//$83 = ($79f0 & #0c) + #64;
	//$80 = $82 = 0;
	//$81 = #60;
	$80,81 = #6000;
	$82,83 = #6400 + (($79f0 & #c) << 8);
$a962:
	do {
		y = 0;
		do {
			$82[y] = $80[y];
		} while (++y != 0);
$a969:
		$81++; $83++;
	} while (($81 & 3) != 0); //bne a962 $80,81 == $6400 になるまで
$a973:
	$aa67();
	$aa4b();
	return saveMenu::close();	//$a88c();
}
```
</details>

________________________________________________________________________________
# $3d:aa67
<details>

### (pseudo)code:
```js
{
	$a3 = $a2 = 0;
	$a7cd();
	push ( a = (($79f0 >> 2) & 3) );
	x = a + #11;
	field::drawWindowOf();	//aaf1();
	a = #25;
	$a66b();
	pop a;
	a++;
	$8000();
	return $a7cd();
$aa8e:
}
```
</details>

________________________________________________________________________________
# $3d:aaa6
<details>

### (pseudo)code:
```js
{
	field::getWindowParam();	//aabc
	$38++; $39++;
	$3c -= 2;
	$3d -= 2;
	return;
}
```
</details>

________________________________________________________________________________
# $3d:aabc field::get_menu_window_metrics
<details>

### (pseudo)code:
```js
{
	a = $38 = $b6 = $aaf7.x;
	$97 = a - 1;
	a = $39 = $ab1d.x;
	$98 = $b5 = a + 2; $b5--;
	a = $3c = $ab43.x;
	$b8 = a + $b6 - 1;
	a = $3d = $ab69.x;
	$b7 = a + $b5 - 3;
	return;
}
```
</details>

________________________________________________________________________________
# $3d:aaf1 field::draw_menu_window
<details>

### args:
+	[in] x : window id

### (pseudo)code:
```js
{
	field::getWindowParam();	//$aabc();
	return field::drawWindow();	//$ed02();
$aaf7:
}
```
</details>

________________________________________________________________________________
# $3d:aaf7 field::menu_window_metrics
<details>

### (pseudo)code:
```js
{
	//0x26 entries each for left, top, width, and height.
}
```
</details>

________________________________________________________________________________
# $3d:ab8f
<details>

```js
{
}
```
</details>


________________________________________________________________________________
# $3d:ad85 jobMenu::getCosts
<details>

### args:
+	[out] u8 $7200[0x17] : costs

### (pseudo)code:
```js
{
	for ($8f = 0; $8f < #17; $8f++) {
$ad89:
		$adf2();
		$80 = $7c00 >> 4;
		a = $7c08 >> 4;
		$80 = abs( a - $80 );

		$81 = $7c00 & #0f;
		a = $7c08 & #0f;
		$81 = abs( a - $81 );

		$82 = $80 + $81;

		x = ($8f << 1) | $7f;
		$83 = $6210.x;
		a = ($82 << 2) - $83;
		if (a < 0) { //bcs addd
$addb:
			a = 0;
		}
$addd:
		$7200.(x = $8f) = a;
	} //cmp #17; bcs aded; jmp ad89
$aded:
	return call_switch1stBank(a = #3c);	//jmp $ff06
}
```
</details>

________________________________________________________________________________
# $3d:adf2 getJobParameter
<details>

### args:
+	[in] u8 $7f : offset of character
+	[in] u8 $8f : jobId
+	[out] JobBaseParam $7c00 : target job's
+	[out] JobBaseParam $7c08 : current job's

### (pseudo)code:
```js
{
	call_switch1stBank(a = #39);	//ff06
	y = $8f << 3;
	for (x = 0;x < 8;x++,y++) {
$adff:
		$7c00.x = $39:8000.y;
	}
$ae0b:
	x = $7f;
	y = $6100.x << 3;	//00:job
	for (x = 0;x < 8;x++,y++) {
$ae16:
		$7c08.x = $39:8000.y;
	}
	return;
}
```
</details>

________________________________________________________________________________
# $3d:aba3
<details>

### (pseudo)code:
```js
{
	$6110-$6116 = targetjob baseparam
	$6130-$613f = {currentMp,maxMp} [8]
	$39:9b88 = base mp
	$87 <- $6101 (lv)
}
```
</details>

________________________________________________________________________________
# $3d:ac31
<details>

### args:
+	[in] $87 = lv

### (pseudo)code:
```js
{
	while (lv > 0) {
		y = jobindex*2;
		$80 = 3d:ad59[y]
		$81 = 3d:ad5a[y]	//($80)->39:xxxx
		$87--;
		y = ($87)*2
		$82 = ($80),y	//paramup flag,savimNNN (n=increment)
		$84 = $82 & 7
		y++;
		$83 = ($80),y	//mpup flag,87654321
	}
}
```
</details>

________________________________________________________________________________
# $3d:ad45
<details>

### (pseudo)code:
```js
{
	A = A + $84;
	if (A > 99) A = 99;
}
```
</details>

________________________________________________________________________________
# $3d:a2df checkmagic
<details>

### (pseudo)code:
```js
{
	a = $a20c,y //y=magicid (00-37)
	$80 = a //a=flagMask
	a = $a244,y
	$7f = a //a=flagIndex

	x = $3d:a27c,y
	y = $7c00,x

	$7c00,x = itemid of magic
}
```
</details>

________________________________________________________________________________
# $3d:b0eb floor::shop:
<details>

### (pseudo)code:
```js
{
	//...
$b19a:
	$8f74();
	x = $8e;
	if ( $64 == 0) { //bne b1ae
		$60e0.x -= 1;
	}
$b1ae:
	if ( $64 != 0 || $60e0.x == 0) { //bne b1b6
$b1b0:
		$60c0.x = $60e0.x = 0;
	}
$b1b6:
	$80,81,82 = $61,62,63;
$b1c2:
	incrementPartyGil( increment:$80 );
	$b1f2();
	return $b137();
}
```
</details>

________________________________________________________________________________
# $3d:b220 floor::shop::getItemValues
<details>

### (pseudo)code:
```js
{
	for (x = 7;x >= 0;x--) {
$b222:
		$7b80.x = $7b01.x;
	}
	for (y = 0;y < 8;y++) {
$b22d:
		floor::getTreasureGil( treasureParam:x = $7b80.y ); //$f5d4
		$7ba8.y = $80;
		$7bb0.y = $81;
		$7bb8.y = $82;
	}
$b247:
	return;
}
```
</details>

________________________________________________________________________________
# $3d:b248 floor::shop::getSellingPrice
<details>

### args:
+	[out] u24 $61 : price
+	[in] u8 $64 : bulk selling?
+	[in] u8 $8e : selling item index

### (pseudo)code:
```js
{
	if ( $64 == 0 ) { //bne b257
		a = $60c0.(x = $8e);
		floor::shop::getItemValue( itemid:a ); //$b270();
		//jmp b269
	} else {
$b257:
		a = $60c0.(x = $8e);
		floor::shop::getItemValue( itemid:a );
		$80 = $60e0.(x = $8e);
		$8e55();
	}
$b269:
	$61,62,63 >>= 1;
	return;
$b270:
}
```
</details>

________________________________________________________________________________
# $3d:b270 floor::shop::getItemValue
<details>

### args:
+	[in] u8 a : itemid??
+	[out] u24 $61 : gil?

### (pseudo)code:
```js
{
	floor::getTreasureGil( treasureParam:x = a ); //f5d4
	$61,$62,$63 = $80,$81,$82;
	return;
}
```
</details>

________________________________________________________________________________
# $3d:b6da
<details>

### (pseudo)code:
```js
{
	$e4 = $e3;
	$e3 = $e2;
	$e2 = $e1;
	$e1 = $33 & #0f;
	a = $2d >> 1;
	if (!carry) { //bcs b6fa
		a = $44 & #30;
$b6f5:
		$e1 |= a;
		return;
	}
$b6fa:
	if ( ($44 & #04) != 0)  //beq b706
		&& ( ($a5 & 1) == 1) ) //bcc b706
	{
		return;
	}
$b706:
	push (a = ($44 & #34) );
	temp = a & #04;
	pop a;
	if (temp < 4) return $b6f5; //bcc
$b712:
	a = #70; return $b6f5;
}
```
</details>

________________________________________________________________________________
# $3d:b78a
<details>
</details>

________________________________________________________________________________
# $3d:bc5b
<details>

### (pseudo)code:
```js
{
	if (carry) {
		return isEncounterOccured();	//$bdb9();
	} else {
		return $bc68();
	}
}
```
</details>

________________________________________________________________________________
# $3d:bd4d getEncounterId
<details>

### (pseudo)code:
```js
{
	//$81 = y = 0;
	$80,81 = #94f0 + (a << 3);
	x = $fe00.(x = ++$f7) & #3f;
	y = $bd78.x;
	$6a = $80[y];	//$80: $2e:94f0 + ?
	clc;
	return;
$bd78:
	
}
```
</details>

________________________________________________________________________________
# $3d:bdb8
<details>

```js
{
	return;
}
```
</details>

________________________________________________________________________________
# $3d:bdb9 isEncounterOccured
<details>

### args:
+	[in] u8 $48 : warpId
+	[in] u8 $f8 : bound

### (pseudo)code:
```js
{
	if ($6c != 0) bdb8;
	field::getRandom();	//$c711();
	if (a >= $f8) bdb8;
$bdc4:
	call_switch1stBank(per8k:#2e); //ff06
	x = $48;
	if ($78 == 0) { //bne bdda
		a = $92f0.x;
$bdd2:
		getEncounterId();	//$bd4d();
		$ab = #20;
		return;
	}
$bdda:
	a = $93f0.x;
	goto $bdd2;
}
```
</details>
