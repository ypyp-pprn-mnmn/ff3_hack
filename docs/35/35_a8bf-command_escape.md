
# $35:a8bf command_escape

<summary>06: にげる</summary>

## (pseudo-)code:
```js
{
	$78d5 = 1;	//listid
	$78d7 = #3f;	//actionName
	setNoTargetMessage();	//$91ce();
	getActor2C();	//$a42e();
	if (a >= 0) $a8d4	//bpl
	else goto $a978
$a8d4:
	$18,19,1a,1b = 0;
	$24,25 = #7675;
	y = x = 0;
	for (x;x != 8;x++) {
$a8ea:	
		a = $7da7.x
		if (a != #ff) {	//beq $a900
$a8f1:		
			$18,19 += $24[y];	//y=0(lv)
			$1a++;
		}
$a900:
		$24,25 += #0040;
	}
$a912:
	div16();	//$fc92 ($1c = $18/$1a)
	a = $6e[y = #2a] + #19 - $1c;	//2a:jobparam+2?
	if (a < 0) a = 0;	//bcs$a923
$a923:
	$24 = a;	
	getSys1Random(#64);	//a564
	if (a < $24) $a948; //bcc
$a92e:
	if (($78ba & 1) != 0) $a948;	//bne
$a935:
	$78da = #1f;	//"にげられない！"
	return;
$a93b:
}
```




