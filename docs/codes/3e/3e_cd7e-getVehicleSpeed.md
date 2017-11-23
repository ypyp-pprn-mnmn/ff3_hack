
# $3e:cd7e getVehicleSpeed


## args:
+	[in] u8 $42 : vehicle
+	[in] u8 $78 : world
+	[out] u8 $34 : speed (pixel per frame)
+	[in,out] u8 $4e : apply delay (0=yes)
## code:
```js
{
	if ($78 >= 4) { //bcc cd88
		a = 1; //bne cd8d
	} else {
$cd88:
		x = $42;
		a = $cd76.x;
	}
$cd8d:
	$34 = a;
	if (a != #8) { //beq cd98
		$4e = 0;
		return;
	}
$cd98:	//ノーチラスは8
	if ($4e == 0) { //bne $cda2
		$4e++;	
		$34 = 4;//1回だけ増分を4にする
	}
$cda2:
	return;
$cda3:
}
```




