
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


