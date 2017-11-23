
# $2f:ab3d 

### args:
+	[in] u8 $7e : index
+	[out] ptr $1c : dataAddr

### code:
```js
{
	push (a = x);
	if ($7e != #18) { //beq ab54
		if (a == #19) { //beq ab5f
$ab49:
			$1c,1d = #bf00
			//jmp ab7d
		}
	}
$ab54:
	$1c,1d = #bf80
	goto $ab7d;	//jmp ab7d
$ab5f:
	$18 = a;
	$19 = 0;
	$1a = #a0;
	$1b = 2;
	mul16x16();	//fcf5
	$1c,1d += #8000;
$ab7d:
	x = pop a;
	return;
$ab80:
}
```


