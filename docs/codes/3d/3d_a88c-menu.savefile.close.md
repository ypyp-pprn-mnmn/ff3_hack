
# $3d:a88c menu.savefile.close
> 「セーブ」メニューを閉じる。

### args:
+	out u8 $78f0: cursor position y of window-1. set to 0x18 on exit.

### (pseudo)code:
```js
{
	menu.accept_input_action();	//$8f74();
	$78f0 = 0x18;
	return menu.main.erase();	//$a685();
}
```




