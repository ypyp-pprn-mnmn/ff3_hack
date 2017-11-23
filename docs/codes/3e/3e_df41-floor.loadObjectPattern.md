
# $3e:df41 floor::loadObjectPattern


## args:
+	[in] u8 $8a : vramoffset high (base = #1200)
+	[in] u8 $8b : objectOffset
+	[in] ptr $8c : objectIdToPatternIndexMap ($00:9400-)
## code:
```js
{
	if ((a = $700a.(x = $8b)) == 0) return; //beq df40
	y = a;
	call_switch1stBank(per8k:a = #00); //ff06
	if( (a = $8c[y]) < #40) { //bcs df6b
$df54:
	//size=100h
	//前、後ろ、左1、左2
		$80,81 = #8000 + (a << 8);
		call_switchFirst2Banks(per8kBase:a = #0e); //ff03
		x = #01;
		a = $8a + #12;
		return loadPatternToVramEx(); //de0f
	}
$df6b:	else if (a < #58) { //bcs df9f
	//同パターン{前後}x2, size=80h
		$80,81 = #8000 + ( (a - #40) << 7 ); //lsr,ror
		call_switch1stBank(per8k:a = #0a); //ff06
		x = #80;
		y = 0;
		bit $2002;
		$2006 = $8a + #12;
		$2006 = 0;
		loadSmallPatternToVram(len:x, offset:y ); //de2a
		return loadSmallPatternToVram(len:x = #80, offset:y = #00); //$de2a();
	} else {
$df9f:	//同パターンx4, size=40h
		$80,81 = #8800 + ((a - #58) << 6);
		call_switch1stBank(per8k:a = #0d); //ff06
		bit $2002;
		$2006 = $8a + #12;
		$2006 = 0;
		$dfcf();
		$dfcf();
		$dfcf();
$dfcf:
		return loadSmallPatternToVram(len:x = #40, offset:y = #00); //$de2a();
	}
$dfd6:
}
```




