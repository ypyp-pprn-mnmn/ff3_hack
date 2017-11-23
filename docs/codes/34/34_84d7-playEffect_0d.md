
# $34:84d7 playEffect_0d



### (pseudo-)code:
```js
{
	if ($7e9a >= 0) { //bmi 84e6
		if ($78d4 != 0) { //beq 84f5
			call_2e_9d53(a = #21); //fa0e
		}
	} else {
$84e6:
		dispatchPresenetScene_1f();	//$8545();
		if ($78d4 != 0) { //beq 84f5
			$7e = a;
			call_2e_9d53(a = #0d);
		}
	}
$84f5:
	return;
}
```



