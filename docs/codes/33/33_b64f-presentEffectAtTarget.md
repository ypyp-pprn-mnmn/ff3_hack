
# $33:b64f presentEffectAtTarget

### args:
+	[in] u8 $90 : current target index
+	[in] u8 $7300[0x100] : effectFrameParams
+	[in] u8 $7e9a :	actor's char index?
+	[in] u8 $7eb8 : reflected target bits

### code:
```js
{
	$7eb8 <<= 1;
	if (!carry) {	//bcs $b657
		return presentEffectAtTargetWorker();	//$33:b6f3();
	}
$b657:
	$33:a440(a = #b1);
	$33:b5bb();
	$33:a440(a = $7e8d)
	push (a = $90);
	push (a = $7e9a);
	$7e9a = a ^ #40;
	y = 0;x = $90;
	a = $7eb9.x;
	do {
$b678:	
		if (a == $fd24.y) break;
	} while (++y != 0);
$b680:
	$90 = y;
	presentEffectAtTargetWorker();	//$33:b6f3();
	$7e9a = pop a;
	$90 = pop a;
	return;
}
```


