
# $36:8003 soundDriverEntry


## args:
+	[in] u8 $7f43 : ?
+	[in] u8 $7f49 : soundId ( =$ca | #80); #40 = playLast?
## callers:
+	$3f:faf2(irq worker)
## code:
```js
{
	if ($7f43 == #37) { //bne $8011
$800a:
		$7f49 = 0;
		//beq 8014
	} else {
$8011:
		$8b9d();
	}
$8014:
	$8925();
	$4015 |= #0f;	//4015:soundreg #0f:enable( noise | triangle | square-1 | square-0 )
	$8030();
	$80ab();

	$7f40 <<= 1;
	a = $7f42 << 1;	//
	ror $7f40;	//再生中なら最上位に1
	return;
$8030:
}
```



