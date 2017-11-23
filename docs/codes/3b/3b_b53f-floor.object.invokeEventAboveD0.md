
# $3b:b53f floor::object::invokeEventAboveD0


### args:
+	[in] u8 a : event (d0-ff)

### (pseudo)code:
```js
{
	if (a >= #e4) { //bcc b555
		x = (a - #e4) << 1;
		$80,81 = $b617.x,$b618.x;
		return (*$80)(); //funcptr
	}
$b555:
	x = (a - #d0) << 1;
	$80,81 = $b567.x,$b568.x
	return (*$80)();
$b567: //77567
	8F B5  97 B5  9F B5  A3 B5
	A7 B5  AA B5  AD B5  B2 B5
	B7 B5  BA B5  D7 B5  DA B5
	DF B5  E4 B5  EF B5  FC B5
	4F B6  68 B6  6F B6  72 B6
$b617: //77617
	72 B6  72 B6  72 B6  73 B6
	8E B6  94 B6  9A B6  9D B6
	A0 B6  A3 B6  A6 B6  B4 B6
	BF B6  D5 B6  E0 B6  E5 B6
	EA B6  EF B6  F4 B6  0F B7
	1C B7  50 B7  5E B7  6C B7
	75 B7  9D B7  A2 B7  A3 B7
}
```



