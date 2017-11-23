
# $34:9754 initTileArrayStorage



//fill_7200to73ff_ff
+ [out] u16 $4e,$7ac0 : #7200

### (pseudo-)code:
```js
{
	$7ac0 = $18 = $4e = #$7200;
	memset($18,0xff,0x200);
$9777:
}
```



