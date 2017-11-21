
# $3d:b248 floor::shop::getSellingPrice


## args:
+	[out] u24 $61 : price
+	[in] u8 $64 : bulk selling?
+	[in] u8 $8e : selling item index
## (pseudo)code:
```js
{
	if ( $64 == 0 ) { //bne b257
		a = $60c0.(x = $8e);
		floor::shop::getItemValue( itemid:a ); //$b270();
		//jmp b269
	} else {
$b257:
		a = $60c0.(x = $8e);
		floor::shop::getItemValue( itemid:a );
		$80 = $60e0.(x = $8e);
		$8e55();
	}
$b269:
	$61,62,63 >>= 1;
	return;
$b270:
}
```



