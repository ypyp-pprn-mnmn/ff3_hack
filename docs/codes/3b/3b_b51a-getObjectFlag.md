
# $3b:b51a getObjectFlag


### args:
+	[in] u8 a : objectId?
+	[in] u8 $78 : world
+	[in] $6080[2][0x20] : flags (1bit per id)

### (pseudo)code:
```js
{
	$80 = a;
	x = a & 7;
	$81 = $b537.x;
	a = $80 >> 3;
	if ((x = $78) != 0) { //beq b530
		a += #20;
	}
$b530:
	a = $6080.(x = a) & $81;
	return;
$b537:
	01 02 04 08 10 20 40 80
}
```



