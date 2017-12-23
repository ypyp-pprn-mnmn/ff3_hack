
# $3d:a9e1 menu.savefile.draw_file_summary
>指定のゲームデータの内容をウインドウに描画する。ファイルが存在しない場合は描画をスキップする。

### args:

#### in:
+	u8 A: higher byte of addres of the file (0x64, 0x68, 0x6c)

#### out:
+	bool carry: is file available. where:
	+ 1 = available.
	+ 0 = unavailable. (therefore window hasn't drawn.)

### callers:
+	`1E:A9AF:20 E1 A9  JSR menu.savefile.draw_summary` file1 @$3d:a9a0 menu.savefile.build_file_menu
+	`1E:A9BB:20 E1 A9  JSR menu.savefile.draw_summary` file2 @$3d:a9a0 menu.savefile.build_file_menu
+	`1E:A9C7:20 E1 A9  JSR menu.savefile.draw_summary` file3 @$3d:a9a0 menu.savefile.build_file_menu

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
	//write code here
	push(a);
	$3d$ae97(a = (a >> 3) & 3);
	if (carry) {
		pop();
		clc;
		return;
	}
	menu.savefile.load_game_at({address_high: pop()});	//$a9f9;
	field.draw_menu_window_content({text_id: 0x25});	//$a66b
	sec;
	return;
}
```

