
# $3b:b2fd floor::loadObjects


+	ptr $2c:8000[0x100] : index = $0784 (warpparam.+04)

### (pseudo)code:
```js
{
	do {
		$7000.x = 0;
	} while (++x != 0);
	call_switch1stBank(per8k:a = #2c);	//ff06
	$80,81 = #8000 + ($0784 << 1);
	$8c,8d = #8000 | ($80[y],$80[++y]);
	$8a,8b = #7100;
	$8e,8f = #7000;
$b336:
	while ($8c[y = 0] != 0) { //beq b34d
		floor::loadObject();	//$b34e();
		$8c,8d += 4;
	}
$b34d:
	return;
}
```



