
# $2f:b352 moveCharacterBack

### code:
```js
{
	$7d7d = #1;
	y = x << 1;
	if (($7d9b.y & 8) != 0) {
		$7e = #f0;
		$7d7d = 0;
		//jmp b37f
	} else 
$b36d:
		if (($7d8f.x & 1) != 0) { //beq b37b
			$7e = #20;
			//jmp b37f
		}
$b37b:
		$7e = #10;
	}
$b37f:
	$7d7f.x += $7e;
	return $b45c();
$b388:
}
```


