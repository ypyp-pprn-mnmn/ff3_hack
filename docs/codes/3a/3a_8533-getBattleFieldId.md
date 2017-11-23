
# $3a:8533 getBattleFieldId


## args:
+	`[in] u8 $48 : warpId`
## (pseudo)code:
```js
{
	call_switch2ndBank(per8k:a = #39); //ff09
	x = $48;
	if ( $78 != 0) { //beq 8546
$853e:
		$6b = $53 = $bd00.x;
		return;
	}
$8546:
	$6b = $53 = $bc00.x;
	return;
$854e:
}
```



