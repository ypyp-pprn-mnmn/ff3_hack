
# $3d:aabc menu.get_window_metrics
> 各種メニューウインドウのメトリック(サイズ・位置)を取得する。

### args:
+	in u8 X: window_id

### notes:
the window id has diffrent meaning to the analogous logic implemented for floor-mode (`$3f:ed61 field.get_window_region`).

### (pseudo)code:
```js
{
	a = $38 = $b6 = $aaf7.x;
	$97 = a - 1;
	a = $39 = $ab1d.x;
	$98 = $b5 = a + 2; $b5--;
	a = $3c = $ab43.x;
	$b8 = a + $b6 - 1;
	a = $3d = $ab69.x;
	$b7 = a + $b5 - 3;
	return;
}
```





