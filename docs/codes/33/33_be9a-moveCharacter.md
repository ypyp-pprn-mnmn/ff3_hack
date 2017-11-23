
# $33:be9a moveCharacter	

>effect_14

### args:
+	[in] u8 $7d7f[4] : goalX

### code:
```js
{
	$33:be89
	loadCharacter();	//$32:9f11 = effect_03 = call_2e_9d53(#13)
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5
	for (x = 0;x != 4;x++) {
		a = $c0.x;
		if (a != $7d7f.x) $be9a;
	}
	return;
$beb2
}
```


