
# $35:ba41 processPoison

<summary></summary>

## (pseudo-)code:
```js
{
	a = #ff;
	for (x = #1f;x >= 0;x--) {
		$7400.x = a;
	}
	$64 = 0;
	$24 = 8;
	$28,29 = #7575;
	for ($24;$24 != #0c;$24++) {
		getPoisonDamage();	//$badc();
		$28,29 += #40;
	}
$ba73:
	$9d06();
	$24 = 0;
	$28,29 = #7675;
	for ($24;$24 != #08;$24++) {
$ba82:
		getPoisonDamage();	//$badc();
		x = $24;
		$7ec4.x = $28[y = #01];
		$28,29 += #40;
	}
$baa3:
	if ($64 != 0) { //beq $badb
		for (x = #1f;x >= 0;x--) {
			$7e4f.x = $7400.x;
		}
$bab2:
		$7e98 = $7e99 = #80;
		$7e9a = (a >> 1); //=#40
		$78d5 = #05;
		$78da = #41;
		$7ec2 = #17;
		presentBattle();	//8ff7
		$7ec2 = #16;
		$83f8();
		canPlayerPartyContinueFighting();	//$a458();
	}
$badb:
	return;
}
```



