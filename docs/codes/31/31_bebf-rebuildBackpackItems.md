
# $31:bebf rebuildBackpackItems 

<summary>battleFunction08</summary>

## (pseudo-)code:
```js
{
	a = 0;x = 0;
	do {
$bec3:
		$7280.x = $7380.x = a;
	} while (++x != 0);
$becc:
	for (y = 0;y != #40;y++) {
$bece:
		x = a = $60c0.y;	//itemid (in battle allocation)
		$7280.x = a;
		y++;
		a = $7380.x + $60c0.y;	//itemcount (battle)
		if (a >= 100) { //bcc bee3
			a = 99;
		}
$bee3:
		$7380.x = a;
	}
$beeb:
	a = 0;
	for (x = #3f;x > 0;x--) {
		$60c0.x = a;
	}
$bef5:
	for (y = #ff, x = 0; y != 0; y--) {
$bef9:
		if ((a = $7280.y) != 0) { //beq bf13
$befe:
			$60c0.x = a; x++;
			if ((a = $7380.y) == 0) { //bne bf0f
				x--;
				$60c0.x = 0;
			} else {
$bf0f:
				$60c0.x = a; x++;
			}
		}
$bf13:
	}
	return;
}
```



