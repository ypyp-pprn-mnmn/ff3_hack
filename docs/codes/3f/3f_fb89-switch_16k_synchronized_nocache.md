
# $3f$fb89 switch_16k_synchronized_nocache


### args:
+	[in] u8 A : bankNo (per _16k_ unit)
+	[out] u8 $ab : per16kBankNo

### local variables:
+	u8 $a9 : page_lock (コマンド発行中のみincr)
@see `$3f$fb87 switch_16k_synchronized`

```js
{
$fb89:
	push(a << 1);
	a = #06;
	$a9++;
	$8000 = a;	//commandId	pop(a);
	$8001 = pop();	//per8k bankNo
	$a9--;
	a++;
$fb9b:
	push(a);
	a = #07;
	$a9++;
	$8000 = a;
	$8001 = pop();
	$a9--;
}
```	



