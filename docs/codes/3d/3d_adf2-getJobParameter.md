
# $3d:adf2 getJobParameter


### args:
+	[in] u8 $7f : offset of character
+	[in] u8 $8f : jobId
+	[out] JobBaseParam $7c00 : target job's
+	[out] JobBaseParam $7c08 : current job's

### (pseudo)code:
```js
{
	call_switch1stBank(a = #39);	//ff06
	y = $8f << 3;
	for (x = 0;x < 8;x++,y++) {
$adff:
		$7c00.x = $39:8000.y;
	}
$ae0b:
	x = $7f;
	y = $6100.x << 3;	//00:job
	for (x = 0;x < 8;x++,y++) {
$ae16:
		$7c08.x = $39:8000.y;
	}
	return;
}
```



