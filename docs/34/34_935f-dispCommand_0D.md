
# $34:935f dispCommand_0D	//dying effect?

<summary></summary>

## args:
+ [in] u8 $78d3 : ?
## (pseudo-)code:
```js
{
	a = $78d3 & 2;
	if (a != 0) return;	//bne $93c1;
$9369:	
	getActor2C();	//$35:a42e();
	if (a >= 0)  {	//bmi $9392;
$936e:
		a = $6e[y = #30];	//actor.30
		if (a >= 0) {	//bmi $9383;
$9374:
			setTableBaseAddrTo$00e0();	//$34:95cf
			$34:93cd();
			setTableBaseAddrTo$00f0();	//$34:95d8
			$34:93cd();
$9383:		} else {
			setTableBaseAddrTo$00f0();	//$34:95d8
			$34:93cd();
			setTableBaseAddrTo$00e0();	//$34:95cf
			$34:9408();
		}
	} else {
$9392:		
		a = $6e[y = #30];	//actor.30
		if (a >= 0) {	//bmi $93a7;
$9398:
			setTableBaseAddrTo$00e0();	//$34:95cf
			93cd;
			setTableBaseAddrTo$00f0();	//$34:95d8
			9408;
$93a7:		} else {
			setTableBaseAddrTo$00f0();	//$34:95d8
			9408;
			setTableBaseAddrTo$00e0();	//$34:95cf
			9408;
		}
	}
$93b3:
	$34:9474();
	$34:9d06();
$93b9:	$7ec2 = #16;
	playEffect();	//$34:8411();
$93c1:
	return;	//jmp $9051
}
```



