
# $34:9ae7 putCanceledItem

<summary></summary>

## (pseudo-)code:
```js
{
	$18 = a;
	$5b[y] = 0;
	a = $5b[--y];
	if (a == 0) { //bne 9b1c
		for (x = 0;x != #40; x+=2) {
$9af4:
			a = $60c0.x;
			if (a == $18) { //bne 9b02
				x++;
				$60c0.x++;
				goto $9b1c;
			}
$9b02:
		}
$9b08:
		for (x = 0;x != 0;x++) {
$9b0a:
			a = $60c0.x;
			if (a == 0) $9b13
		}
$9b13:
		$60c0.x = $18; x++;
		$60c0.x++;
	}
$9b1c:
	$5b[y] = 0;
	return;
}
```



