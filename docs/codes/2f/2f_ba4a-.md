
# $2f:ba4a 

### code:
```js
{
	$80 = a; $81 = x;
	$7e,7f = #7900;
	$86 = 7;
		//$af48();
	if ( is_backattacked_2f() ) { //bne $ba69
$ba5f:
		offset$7e(#8);	//$f8f2(8);
		offset$80(#8);	//$f8fe(8);
	}
	for ($86;$86 != 0;$86--) {
$ba69:
		waitNmi();	//fb80;
		put16hTilesFrom$7e();	//$ba8e();
		offset$7e(#20);	//$f8f2(#20);
		offset$80(#20);	//$f8fe(#20);
		put16hTilesFrom$7e();	//$ba8e();
$ba7c:
		offset$7e(#20);	//$f8f2(#20);
		offset$80(#20);	//$f8fe(#20);
		updatePpuScrollNoWait();	//$f8cb();
	}
	return;
$ba8e:
}
```


