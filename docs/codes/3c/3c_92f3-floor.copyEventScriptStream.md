
# $3c:92f3 floor::copyEventScriptStream


## (pseudo)code:
```js
{
	x = 0;
$92f5:
	while ($7b00.x != #ff)
	{
		while (	$7b00.(++x) != #ff) {}
		x+=2;
	}
$9309:
	x += 2;
	for (y = 0;y < #20;x++,y++) {
		$0740.y = $7b00.x;
	}
$9319:
	x = 0;
$931b:
	if ((a = $7b00.x) == #ff) { //bne 9328
		$6c = $7b01.x;
		return;
	}
$9328:
	if (a < 0) { //bpl 9332
		x++;
		getEventFlag();	//$9344();
		if (!equal) $931b;
		//beq 9338
	} else {
$9332:
		x++;
		getEventFlag(); //$9344
		if (equal) $931b;
	}
$9338:
	while ($7b00.x != #ff) { x++; } //bne 9338
	x++;
	return $931b;
}
```



