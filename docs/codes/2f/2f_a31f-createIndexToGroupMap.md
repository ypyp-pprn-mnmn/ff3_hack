
# $2f:a31f createIndexToGroupMap

### args:
+  [in]
+	u8      $7d7b : enemy_graphics_layout_id
+   u8[4]   $7d6f : number_of_enemies_spawned
+	[4]     $a4da : { u8[4] placement }

### code:
```js
{
	a = #ff;
	for (x = 8;x != 0;x--) {
		$7da6.x = a;
		$7dae.x = a;
	}
	$7e,7f = ($7d7b << 2) + #a4da;
$a33e:
	for (y = 0;y != 4;y++) {
		if ((a = $7e[y] ) != #ff) { //beq a346
			$8c = a;
		}
$a346:
		for ($82 = $7d6f.y ; $82 != 0; $82--) { //beq a35c
			x = $8c;
			$7daf.x = $7da7.x = y;
			$8c++;
		}
$a35c:
	}
}
```


