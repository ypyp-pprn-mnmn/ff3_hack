
# $3e:cc47 field::loadMapRow


### code:
```js
{
	field::getMapDataPointers();	//$ccbb();
	for ($82;;) {
		if ( (a = $80[y = 0] ) < 0) { //bpl cc73
$cc50:
			$84 = a & #7f;
			$80,81++;
			x = $80[y];
			a = $84;
			for (x;x != 0;x--) {
$cc5f:
				$82[y++] = a;
			}
			if ((a = y) != 0) { //beq cc82
				y = 0;
				$82 += a;
				//bcc cc79 bcs cc82
			}
		} else {
$cc73:
			$82[y] = a;
			$82++;
		}
		if ($82 == 0) break;  //beq cc82
		$80,81++;
	}
$cc82:
	return;
}
```




