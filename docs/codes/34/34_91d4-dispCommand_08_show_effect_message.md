
# $34:91d4 dispCommand_08_show_effect_message



### args:
+ [in] u8 $78d9 : effect id? (#ff = display nothing)

### (pseudo-)code:
```js
{
	a = $78d9;
	if (a == #ff) return; //beq $91fb
	$1a = a + #0c;
	loadString(index:a = $1a, dest:x = 0, base:$18 = #8200);	//a609
	strToTileArray($18 = 8);	//966a
	draw1RowWindow(a = 3);
$91fb:	return;		//jmp $9051
$91fe:
}
```



