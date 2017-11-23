
# $34:9450 dispCommand_0A_waitForAButtonDownOrMessageTimeOut

<summary></summary>

## args:
+ [in] u8 $6010 : ?
//
## (pseudo-)code:
```js
{
	a = 8 - $6010;	//user option:message speed?
	a <<= 3;	//$fd3f()
	$24 = a;
	if (a == 0) return;	//beq $9471
	do {
$945f:
		presentCharacter();	//$34:8185();
		getPad1Input();		//$3f:fbaa();
		a = $12 & 1;
		if (a != 0) break;	//bne $9471;
	} while (--$24 != 0);
$9471:
	return;	//jmp $9051
$9474:
}
```



