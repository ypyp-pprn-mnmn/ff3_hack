
# $3e:c72c floor::getObjectEventPtr


### args:
+	[in] u8 a : index (= $6c)
+	[out] ptr $72 : = $2c:8600[index]

### code:
```js
{
	y = a << 1;
	x = #86;
	if (carry) { //bcc c733
		x++;
	}
	$81 = x;
	$80 = 0;
	call_switch1st2Banks(per8kbase:a = #2c); //ff03
	$72,73 = $80[y,++y];
	$6c = 1;
	$17 = 0;
	return;
}
```




