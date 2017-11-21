
# $3f:f38a getLastValidJobId


## code:
```js
{
	a = $6021 & #1f;
	x = 0;
	a >>= 1;
	if (!carry) goto $f3aa;
	x = #05;	//05:あかまどうし
	a >>= 1;
	if (!carry) goto $f3aa;
	x = #09;	//09:がくしゃ
	a >>= 1;
	if (!carry) goto $f3aa;
	x = #10;	//10:ぎんゆうしじん
	a >>= 1;
	if (!carry) goto $f3aa;
	x = #13;	//13:まかいげんし
	a >>= 1;
	if (!carry) goto $f3aa;
	x = #30;
$f3aa:
	a = x;
	return;
}
```



