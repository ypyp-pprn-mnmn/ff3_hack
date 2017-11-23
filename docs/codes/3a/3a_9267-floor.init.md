
# $3a:9267 floor::init


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



