
# $3b:b6bf floor::object::event::F0


### args:
+	[out] ptr $94 : string ptr
+	[out] u8 $76 : string Id

### (pseudo)code:
```js
{
	$76 = $0740.(x = $71);
	a = #84;
	if ((x = $78) != 0) { //beq b6ce
		a = #86;
	}
$b6ce:
	$95 = a;
	$94 = 0;
	return;
}
```



