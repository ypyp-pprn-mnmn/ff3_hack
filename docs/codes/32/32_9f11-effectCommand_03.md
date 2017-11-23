
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


