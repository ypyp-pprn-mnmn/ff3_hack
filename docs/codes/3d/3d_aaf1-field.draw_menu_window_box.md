

# $3d:aaf1 field.draw_menu_window_box
>各種メニューにおいて各ウインドウの枠と背景を描画する

### args:
+	[in] x : window id

### (pseudo)code:
```js
{
	field.get_menu_window_metrics();	//$aabc();
	return field.draw_window_box();	//$ed02();
$aaf7:
}
```




