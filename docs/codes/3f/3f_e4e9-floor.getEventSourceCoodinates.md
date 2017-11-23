
# $3f:e4e9 floor::getEventSourceCoodinates


### args:
+	[in] a : input bits?
+	[out] $84 : mapX
+	[out] $85 : mapY

### code:
```js
{
	a >>= 1;
	if (carry) e500
	a >>= 1;
	if (carry) e507
	a >>= 1;
	if (carry) e4f9
$e4f2:
	x = 7; y = 6; goto e50b;
$e4f9:
	x = 7; y = 8; goto e50b;
$e500:
	x = 8; y = 7; goto e50b;
$e507:
	x = 6; y = 7;
$e50b:
	$84 = ($29 + x) & #3f;
	$85 = ($2a + y) & #3f;
}
```




