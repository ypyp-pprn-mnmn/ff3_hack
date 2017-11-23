
# $3d:a897 fieldMenu::OnSaveSelected


## notes:
$24:a $25:b

## (pseudo)code:
```js
{
	//...
$a8e3:
	$79f0 = 0;
	$a984();
$a8eb:
	do {
		$a7cd();	//cursor?
		a = ($79f0 >> 2) & 3;
		$8241();
		a = 4;
		$91d9();
		if ($25 != 0) $a88c;	//b
	} while ($24 == 0); //beq a8eb:
$a905:
	$8f74();
	a = #4c;
	$a996();
	$a2 = 1;
	$78f0 = 0;
$a916:
	do {
		$a7cd();
		a = ($79f0 >> 2) & 3;
		$8241();

		fieldMenu::updateCursorPos(incr:a = 4);	//$91a3();
		if ($25 != 0) $a935; //b
	} while ($24 == 0); //beq $a916
$a930:
	if ($78f0 != 0) goto $a88c; //beq a938 まえのデーターをけします  rｧいいえ
$a938:
	//rｧはい
	a = #4d;
	$a996();
	
	a = $7f3a + 1;
	if (a >= 100) { //bcc a949
		a = 1;
	}
$a949:
	$7f3a = a;
	//$83 = ($79f0 & #0c) + #64;
	//$80 = $82 = 0;
	//$81 = #60;
	$80,81 = #6000;
	$82,83 = #6400 + (($79f0 & #c) << 8);
$a962:
	do {
		y = 0;
		do {
			$82[y] = $80[y];
		} while (++y != 0);
$a969:
		$81++; $83++;
	} while (($81 & 3) != 0); //bne a962 $80,81 == $6400 になるまで
$a973:
	$aa67();
	$aa4b();
	return saveMenu::close();	//$a88c();
}
```



