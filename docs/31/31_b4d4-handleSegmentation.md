
# $31:b4d4 handleSegmentation

<summary>specialHandler11: 分裂</summary>

## (pseudo-)code:
```js
{
	//if ($6e[y = 3] != $6e[y = 5])	//bne $b4eb
	//if ($6e[y = 4] != $6e[y = 6])	//bne $b4eb
	if ($6e[y = 3] == $6e[y = 5] && $6e[y = 4] == $6e[y = 5]) {
$b4e8:	//[HP==maxHP]
		$31:b98b();
	}
$b4eb:
	$31:b936();
	$31:b9a0();
	return $b4cf();
}
```



