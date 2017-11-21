
# $3f:e6be floor::event07


## code:
```js
{
	x = $45 & #0f;
	push (a = $0720.x);
	switch1stBankTo2C();	//$eb23();
	x = pop a << 1;
	$82,83 = $8880.x,$8881.x;

	$ea1b();	//*$82 => 7b00
	switch1stBankTo3C();	//$eb28();
	$3c:9274();
	$3c:9319();
	$e9dd();
	$2d >> 1;
	if (carry) goto $e714; //bcc e714
$e6eb:
	a = $44;
	return $e3b4();
}
```




