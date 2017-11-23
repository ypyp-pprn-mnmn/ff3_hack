
# $34:91fe dispCommand_09_show_message



### args:
+ [in] u8 $78da.x : message queue?(item=message id;#ff = display nothing)
+ [in] u16 $78e4.x : message params
+ [in] u8 $78ee : queue index?
+ [in] u8 $78ef : message param index?

### (pseudo-)code:
```js
{
	$18 = 0; 
	x = $78ee; a = $78da.x;
	if (#ff == a) return;	//beq $91fb
	//a : message, valid range = 00-8f
	a >>= 1; ror $18;
	x = a;
	a = $9575.x;	//x : higher 7bits of $78da.$78ee
	$18 <<= 1;	//$18 : bit7 is lsb of $78da.$78ee
	if (!carry) { a >>= 4; //$3f:fd45(); }
$921a:	a &= #f;
//here a : 
//	lsb of $78da.$78ee == 1 then $9575.x & #f
//	otherwise $9575.x >> 4
 
	$18 = #956b + (a << 1);	
	$1a,1b = *($18,19);
	(*$1a)();	//jumptable
$9236:
	$78ee++;
	return;	//jmp $9051
$923c:
}
```



