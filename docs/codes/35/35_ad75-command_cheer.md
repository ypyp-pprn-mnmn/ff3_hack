
# $35:ad75 command_cheer



>12: おうえん


### notes:
右手攻撃力+10

### (pseudo-)code:
```js
{
	$78d5 = 1;
	$78d7 = #4b;
	$78da = #31;
	$18,19 = #7575;

	for (x = 4;x != 0;x--) {
$ad8e:
		a = $18[y = #19] + #0a;
		if (carry) { //bcc ad9c
			$78d8 = a = #ff;
		}
$ad9c:
		$18[y] = a;
		$18,19 += #0040;
	}
	return;
$adaf:
}
```



