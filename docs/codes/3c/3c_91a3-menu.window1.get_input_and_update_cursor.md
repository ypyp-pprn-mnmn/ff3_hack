

# $3c:91a3 menu.window1.get_input_and_update_cursor
> メニューの1つ目のウインドウ($7800で管理)用にパッド入力を取得し、必要に応じてカーソル位置の情報を更新する。描画はしない。

### args:
+	in u8 A: offset delta for up/down key
+	in,out u8 $78f0: byte offset of selected item (each menu item consists of 4-byte structure)
+	in u8 $78f1: last valid offset of the view

### (pseudo)code:
```js
{
	$06 = a;
	menu.get_input_and_queue_SE();	//$9175();
	$80 = a & 0xf;
	if (a == 0) return;	//beq 91c8
	if (a < 4) { //bcs 91b6
$91b2:
		$06 = x = 4;
	}
$91b6:
	if ((a & 5) == 0) { //bne 91c9
$91ba:
		a = $78f0 - $06;
		if (a < 0) { //bcs 91c5
			a += $78f1;
		}
$91c5:
		$78f0 = a;
		return;
	}
$91c9:
	a = $78f0 + $06;
	if (a < $78f1) $91c5;
	a -= $78f1;
	goto $91c5;	//if (a >= 0) $91c5;	//always satisfied.
$91d9:
}
```

