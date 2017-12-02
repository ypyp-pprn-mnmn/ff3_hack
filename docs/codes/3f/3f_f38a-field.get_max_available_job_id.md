



# $3f:f38a field.get_max_available_job_id
> calculates the maximum job_id available to palyer, and returns it in the register A.

### args:
-	in u8 $6021 : event flags, [...fffff] where lower 5 bits represents each Crystal event
-	out u8 A : maximum available job_id in accordance with game flags

### callers:
-	`jsr field.get_max_available_job_id  ; F17E 20 8A F3` @ textd.eval_replacement (handler for 0x1e)

### notes:
this function has also set X to the same value of A on exit, however, no callers uses X as such.

### code:
```js
{
	a = $6021 & 0x1f;
	x = 0;
	a >>= 1;
	if (!carry) goto $f3aa;
	x = 0x05;	//05:あかまどうし
	a >>= 1;
	if (!carry) goto $f3aa;
	x = 0x09;	//09:がくしゃ
	a >>= 1;
	if (!carry) goto $f3aa;
	x = 0x10;	//10:ぎんゆうしじん
	a >>= 1;
	if (!carry) goto $f3aa;
	x = 0x13;	//13:まかいげんし
	a >>= 1;
	if (!carry) goto $f3aa;
	x = 0x30;
$f3aa:
	a = x;
	return;
}
```






