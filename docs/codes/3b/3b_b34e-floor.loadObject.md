
# $3b:b34e floor::loadObject


## args:
+	[in] u8 $78 : world
+	[in] u8 a : objectId? (= $8c[0] )
+	[in,out] ptr $8a : ? ( = #7100) [out] += #10
+	[in] ObjectParam* $8c : from $2c:8000 + [ $2c:8000[ $0784] ]
+	[in,out] RuntimeObject* $8e : ( = #7000) [out] += #10
+	$01:9e00[0x200] : [aaaabbbb] a:? ->$7103 b:? ->$7102
## (pseudo)code:
```js
{
	y = $8e[y = #0a] = a;
	getObjectFlag();	//$b51a();
	if (!equal) { //beq b359
		a = y;
	}
$b359:
	$8e[y = 0] = a; //フラグ($6080-)がクリアされていたら0,otherwise =objectid
	$84 = $8e[y = 2] = $8e[y = 4] = $8c[y = 1]; //1:++y
	$85 = $8e[y = 3] = $8e[y = 5] = $8c[y = 2];
	a = $86 = $8c[y = 3];
	$8e[y = 1] = a & #f0;
$b380:	$8e[y = 6,7,8,9] = a = 0;
$b38f:	$8e[y = #0b,#0c,#0d,#0e] = 0;
$b399:
	y = #0f;
	getObjectBuilderAddress(); //$b3f8();
	$8e[y] = a;
	$8e[--y] = x;
	a = ($86 << 4) & #c0;
	$8a[y = #05] = a; //7105+offs
	getChipIdAtObject();	//$b0c5(); [out] y = chipId
$b3b3:
	$8a[y = 0] = a = $0400.y & #37;
	$8a[++y] = a;
	$8a[y = #06] = a & #03;
	call_switch1stBank(per8k:a = #01); //ff06
	y = $8e[y = #0a];
	a = $9e00.y;
	if ( (x = $78) != 0) { //beq b3d9
		a = $9f00.y;
	}
$b3d9:
	push a;
	$7102.(y = $8e) = a & #0f; //$8e = index*0x10
	$7103.y = (pop a) >> 4;
	call_switch1stBank(per8k:a = #2c); //ff06
	$8a = $8e = $8e + #10;
	return;
$b3f8:
}
```



