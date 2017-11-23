
# $3e:d1b1 field::loadString


## args:
+	[in] a : string id (ptrTable = $30200)
+	[out] u8 $7b00 : = 0
+	[out] string $7b01
## code:
```js
{
	push a;
	call_switchFirst2Banks(per8kbank:a = #18);	//ff03
	$82,83 = #8200;
	y = pop a << 1;
	if (carry) { //bcc d1c6
		$83++;
	}
$d1c6:
	$80 = $82[y]; y++;
	push (a = $82[y] );
	$81 = a & #1f | #80;
	
	a = (pop a >> 5) + #18;	//high>>5+#18
	call_switchFirst2Banks(per8kbank:a );

	$7b00 = y = 0;
$d1e5:
	do {
		if ( ($80[y] < #28) //bcs d200
$d1eb:			&& ($80[y] >= #10) ) //bcc d200
		{
			if ($80[y] == #10) //bne d1f3
$d1f1:
				a = $9e;
			}
$d1f3:
			$7b01.y = a; y++;
			$7b01.y = $80[y];
			continue; //jmp $d1e5
		}
$d200:
		$7b01.y = a; y++;
	} while (a != 0); //bne d1e5
$d208:
	return call_switchFirst2Banks(per8kBank:a = #3c);	//jmp ff03
}
```




