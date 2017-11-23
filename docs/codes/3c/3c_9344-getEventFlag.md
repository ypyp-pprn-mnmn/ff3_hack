
# $3c:9344 getEventFlag?


### (pseudo)code:
```js
{
	push (a & #7f);
	y = a & 7;
	$80 = $935a.y;
	y = pop a >> 3;
	a = $80 & $6020.y;
	return;
$935a:
	01 02 04 08 10 20 40 80
}
```



