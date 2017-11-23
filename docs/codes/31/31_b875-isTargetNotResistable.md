
# $31:b875 isTargetNotResistable

<summary></summary>

## args:
+ [in] u8 status
+ [out] bool carry : (1=yes)
## (pseudo-)code:
```js
{
	clearEffectTargetIfMiss();	//$b921();
	a = $70[y = #24] & $24;	//#24:resistStatus
	if (a == 0) { //bne b883
		sec
	} else {
		clc
	}
	return;
}
```



