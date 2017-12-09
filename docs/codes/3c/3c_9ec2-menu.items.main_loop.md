
# $3c:9ec2 menu.items.main_loop
> メニューから「アイテム」を選択したときに実行され、UIの処理を行うメインのループ。

### args:
+	yet to be investigated

### callers:
+	$3d:a52f menu.main_loop

### local variables:
+	yet to be investigated

### notes:
-	the window lists backpack items is using:
	-	window type #6
	-	dialog handler #3 (structure at $7a00 initializied with charcode 0x17).
-	the window lists player characters for items to be targeted is using:
	-	window type #7
	-	dialog handler #2 (at $7900)

### (pseudo)code:
```js
{
	//write code here
}
```
