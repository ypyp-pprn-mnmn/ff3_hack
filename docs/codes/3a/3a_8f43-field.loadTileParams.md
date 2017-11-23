
# $3a:8f43 field::loadTileParams


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



