
# $35:b8fd isPlayerAllowedToUseItem

<summary></summary>

## args:
+ [in] u8 $18 : itemid
+ [in] u16 $20 : ? itemDataBase = #$9400
+ [out] u8 $1c : allowed (1:ok 0:not)
+ [out] u8 $7478[8] : itemParams
## (pseudo-)code:
```js
{
	loadTo7400FromBank30(id:$18, size:$1a = #8, dest:x = #78);	//$ba3a();
	$38 = ($747f & #7f);
	x = $38 * 3;
	$3f:fd8b();
	$38,39,3a = $3b,3c,3d
	y = updatePlayerOffset();	//$a541();
	a = $57[y];	//job
	$b93e();
$b92a:
	$1c = x = 0;
	for (x = 0;x != 3;x++) {
$b92e:
		a = $38.x & $3b.x
		if (a != 0) goto $b93b;	//bne $b93b 
	}
$b93b:
	$1c++;
$b93d:	return;
}
```



