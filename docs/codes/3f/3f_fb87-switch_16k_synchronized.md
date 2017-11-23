
# $3f:fb87 switch_16k_synchronized


### args:
+	[in] u8 A : bankNo (per _16k_ unit)
+	[out] u8 $ab : per16kBankNo

### code:
```js
{
	$ab = a;
$fb89:
	return switch_16k_synchronized_nocache();	//fall through.
}
```


**fall through**

