
# $33:b19b invertHorizontalIfBackattack

### code:
```js
{
	if (is_backattacked_32()) //$32:90d2()
	{	//bne $b1b3
		$0200.x = ($0200.x ^ #ff) - 8;	//x = #ff - x - 8
		$01ff.x = ($01ff.x ^ #40);	//bit6:水平反転?
	}
$b1b3:
}
```


