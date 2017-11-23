
# $3f:ea04 floor::loadEventScriptStream


### args:
+	[in] u8 a : scriptId (= runtimeobject.+00)
+	[in] u8 x : ptr address high ($78 == 0 then #82, otherwise #84)
+	[out] $7b00 : scripts (40h bytes)
+	ptr $82 : = $2c:8200[scriptId]

### code:
```js
{
	y = a << 1;
	if (carry) { //bcc ea09
		x++;
	}
$ea09:
	$81 = x;
	$80 = 0;
	switch1stBankTo2C();	//$eb23();
	$82,83 = $80[y,++y];
}
```


**fall through**

