
# $3c:937e floor::searchSpaceForItem


### args:
+	[in] u8 $80 : itemid
+	[out] bool carry : item full
+	[out] u8 x : index

### (pseudo)code:
```js
{
	for (x = 0;x < 0x20;x++) {
$9380:
		if ( $60c0.x == $80) goto $9399;
	}
$938c:
	for (x = 0;x < 0x20;x++) {
$938e:
		if ( $60c0.x == 0) goto $9399;
	}
	//here carry is set
	return;
$9399:
	clc;
	return;
}
```



