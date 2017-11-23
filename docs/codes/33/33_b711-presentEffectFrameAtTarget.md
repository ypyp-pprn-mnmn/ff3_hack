
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


