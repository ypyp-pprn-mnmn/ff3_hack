
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


