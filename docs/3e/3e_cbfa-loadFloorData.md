
# $3e:cbfa loadFloorData
<summary>32x32のフロアデータを読み込む</summary>

## args:
+	[in] y : initial offset
+	[in] ptr $80 : src
+	[in] ptr $82 : dest (7400)
## code:
```js
{
		if ((a = $80[y] ) < 0) { //bpl cc2a
$cbfe:		//repeated
			$84 = a & #7f;	//chipId
			$80,81++;
			x = $80[y];	//repeat count
			a = $84;
			for (x;x != 0;x--) {
$cc0d:
				$82[y] = a;
				y++;
			}
$cc13:
			if ((a = y) != 0) { //beq cc1f
				$82 += a;
				if (!carry) $cc38 //bcc cc38
			}
			if (++$83 >= #78) cc41 //bcs cc41
			//jmp $cc38
		} else {
$cc2a:
			$82[y] = a;
			if (++$82 == 0) {//bne cc38
				if (++$83 >= #78) cc41 //bcs cc41
			}
		}
$cc38:
		$80,81++;
	}
$cc41:
	return;
}
```




