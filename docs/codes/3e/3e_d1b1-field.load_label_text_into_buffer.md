

# $3e:d1b1 field.load_label_text_into_buffer
> loads into buffer 'label text' specified by string_id.

### args:
+	[in] a : string id (ptrTable = $30200)
+	[out] u8 $7b00 : = 0
+	[out] string $7b01 : buffer.

### notes:
this function is very similar to these logics:
- $3f:ee9a field.load_and_draw_string
- text loaders for particular char codes, found in $3f:eefa textd.draw_in_box.

### code:
```js
{
	push(a);
	call_switch_2banks({per8kbank: a = 0x18});	//ff03
	[$82,$83] = 0x8200;
	y = pop() << 1;
	if (carry) { //bcc d1c6
		$83++;
	}
$d1c6:
	$80 = $82[y]; y++;
	push(a = $82[y]);
	$81 = a & 0x1f | 0x80;
	
	a = (pop() >> 5) + 0x18;	//high>>5+#18
	call_switch_2banks({per8kbank: a});

	$7b00 = y = 0;
$d1e5:
	do {
		if ( ($80[y] < 0x28) //bcs d200
$d1eb:			&& ($80[y] >= 0x10) ) //bcc d200
		{
			if ($80[y] == 0x10) //bne d1f3
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
	return call_switch_2banks({per8kBank: a = 0x3c});	//jmp ff03
}
```





