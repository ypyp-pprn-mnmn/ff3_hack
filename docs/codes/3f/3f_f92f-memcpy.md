
# $3f:f92f memcpy


## args:
+	[in] u16 $7e : sourceAddr
+	[in] u16 $80 : destAddr
+	[in] u8 $82 : len
+	[in] u8 $84 : sourceBank (per16k)
+	[in] u8 $7cf6 : currentBank (bankToRestore)
+	[out] u8 $82 : 0
## code:
```js
{
	switch_16k_synchronized(a = $84);	//$fb87
	for ($82,y = 0;$82 != 0;$82--,y++) {
$f936:		$80[y] = $7e[y];
	}
//jmp $f891
$f891:
	return switch_16k_synchronized(a = $7cf6);	//$fb87
}
```



