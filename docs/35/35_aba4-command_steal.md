
# $35:aba4 command_steal

<summary>0E: ぬすむ</summary>

## (pseudo-)code:
```js
{
	setEffectHandlerTo18();	//ab66
	$78d7 = #47;	//actionName
	$78d5 = 1;	//listId
	a = $70[y = #2c];
	if (a >= 0) {	//bmi $abbf
$abb7:		$78da = #35;	//"ぬすみそこなった"
		return; //jmp $ac64
	}
$abbf:
	a = $6e[y = 0];		//Lv
	a += $6e[y = #f];	//jobLv
	$24 = a;
	getSys1Random(a = #ff);	//$35:a564();
	if (a >= $24) { //bcc $abd6
$abd3:		goto $abb7;	
	}
$abd6:
	a = $70[y = 1] & #e8;
	if (a != 0) goto $abb7;	//bne $abd3
$abde:
	$18 = a = $70[y = #36] & #1f;	//droptable index
	loadTo7400Ex(bank:a = #08,destOffs:x = 0, currentBank:y = #1a,
		base:$20 = #9b80, index:$18, len:$1a = 8); //$3f:fda6
	a = getSys1Random(a = #ff);	//$35:a564();
$ac00:
	if (a < #30) x = 0;
	elif (a < #60) x = 1;
	elif (a < #90) x = 2;
	else x = 3;
$ac1a:
	a = $7400.x;
	if (a == 0) goto $abb7;	//fail to steal
	$25 = a;
	for (x = 0;x != #40; x += 2) {
$ac23:
		a = $60c0.x;
		if (a != $25) continue;	//$ac3b;
		x++;
		$60c0.x++;
		a = $60c0.x;
		if (a < #64) goto $ac5a; //bcc $ac5a
		
		$60c0.x--;
		goto $abb7;	//fail to steal(item full)
$ac3b:	
	}
$ac41:
	for (x = 0;x != #40; x += 2) {
		if (0 == (a = $60c0.x)) goto $ac51;
	}
$ac4e:	goto $abb7;	//fail to steal (no any space for item)
$ac51:
	$60c0.x = $25; x++;
	$60c0.x++;
$ac5a:
	$78e4 = $25;
	$78da = #29;	//"おたから:"
$ac64:	return;
}
```



