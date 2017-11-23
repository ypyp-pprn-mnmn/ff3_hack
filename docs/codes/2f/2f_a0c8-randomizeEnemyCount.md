
# $2f:a0c8 randomizeEnemyCount

### code:
```js
{
	$7e = a;
	push (a = x);
	$21 = 0;
	x = ($7e & #f0) >> 4;
	a = $7e & #0f;
	$7e = getBattleRandom(system:$21, min:x ,max:a );
	x = pop a;
	a = $7e;
	return;
$a0e7:
}
```


