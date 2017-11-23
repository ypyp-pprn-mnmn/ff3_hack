
# $2f:b024 presenetScene_1f 

> [flashEnemy]

### code:
```js
{
	if ($7e9d != #09) { //beq b049
		for ($b6 = 0;$b6 != #08;$b6++) {
$b02f:
			if ( ($b6 & 1) == 0) { //bne b03b
$b035:
				$b04a();
			} else {
$b03b:
				$b04d();
			}
$b03e:
			$af34();
		} //bne b02f
	}
$b049:
	return;
}
```


