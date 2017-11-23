
# $35:aac3 getCurrentTerrain

<summary></summary>

## args:
+ [in] u8 $74c8 : = field $48; warpId
## (pseudo-)code:
```js
{
	a = $7ce3;
	if (a >= 8) { //bcc ab02
		if (a == #12) { //bne aad2
			a = #55; //bne ab05	うずしお
		} else {
$aad2:
			$46,47 = $74c8 + #a24e;
			copyTo7400(base:$46, restore:$4a = #1a, size:$4b = 1, srcBank:a = 0);	//fddc
			if (($7ed8 & 8) == 0) { //bne aafc
$aaf4:
				a = $7400 & f;
				//jmp $ab02
			} else {
$aafc:
				a = $7400 >> 4;	//fd45()
			}
		}
	}
$ab02:
	a += #50;
$ab05:
	return;
$ab06:
}
```



