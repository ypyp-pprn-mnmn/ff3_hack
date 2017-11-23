
# $2f:b38e moveCharacterForward

### args:
+	[in] x : actorIndex
+	[in,out] u8 $7d7f[] : x?

### code:
```js
{
	$7d7d = 0;
	y = x << 1;
	if (($7d9b.y & 8) != 0) { //beq $b3a9
		//backattack?
		$7e = #f0;
		$7d7d = 1;
		//jmp $b3bb;
	} else {
$b3a9:
		if (($7d8f.x & 1) != 0) { //beq $b3b7
$b3b0:
			//backline?

			$7e = #20;
			//jmp $b3bb;
		} else {
$b3b7:
			$7e = #10;
		}
	}
$b3bb:
	$7d7f.x -= $7e;
	return $b45c();
$b3c7:
}
```


