
# $34:986c getCommandInput



### notes:
//[processPlayerCommandInput]

### args:
+ [in]	u8 $52 : playerIndex
+ [in]	u8 $7ed8 : battleMode? (20:invincible)
+ u16 $5b : playerPtr

### (pseudo-)code:
```js
{
//コマンドハンドラが1を返したらここまで
	drawEnemyNamesWindow();	//$34:9d9e()
$986f:	//コマンドハンドラが0を返したらここまで戻ってくる
	x = $52;
	if (x != 4) {
		$7be1 &= ~(1 << x);	//$fd2c
		y = updatePlayerOffset();	//$35:a541();
		y += 2;
		a = $5b[y] & 1;
		if (a != 0) { //beq$9894
			setYtoOffset2F();	//$34:9b94();
			$7e0f.x = $5b[y];	//target
			if (a != 0) $989e
		}
$9894:	
		$78cf.x = #ff;
		$7e0f.x = 0;
	}
$989e:
	drawSelectedActionNames();	//$34:9ba2
	endInputCommandIfDone();	//$34:a433();
	updatePlayerOffset();	//$35:a541();
	x = $52;
	if (0 != (a = $7ce4.x)) { //beq $98bd
$98ae:
		setYtoOffsetOf(a = #23);	//$34:9b88;
		$5b[y] = $7ce4.x;
		$7ce4.x = 0;
	}
$98bd:		
	y = $5f; y++;
	a = $5b[y] & #c0; //dead|stone
	if (a != 0) { //beq $98ce
		$52++;
		$7ceb++;
		goto $986f;	
	}
$98ce:		
	y++;
	a = $5b[y] & #e0;	//paralyze|sleep|confuse
	if (a != 0) { //beq $98d8
		goto $a66c;
	}
$98d8:
	a = $5b[y] & 1;
	if (a != 0)	{ //beq $98e3
		$52++;
		goto $986f;
	}
$98e3:
	createCommandWindow();	//$34:9a69();	//$7400
	setYtoOffset2E();	//$34:9b9b();
$98e9:
	for (x = 2;x >= 0;x--) {
		$5b[y++] = 0;	//y = 2e,2f,30
	}
	setYtoOffsetOf(a = #2c);	//$34:9b88(#2c)
	$5b[y] &= #f7;
	y += 13h;	//y= +3F
	a = $5b[y];
	if (0 != a) {
		putCanceledItem(); //$34:9ae7();
	}
	if (0 == (a = $7cf3)) {
$990f:
		drawEnemyNamesWindow();	//$9d9e
		call_2e_9d53(a = 0);
		a = $7ed8 & #20;
		if (a == 0	//bne 992d
			&& $78ba >= 0) //bmi 992d
$9923:		{
			do {
				getPad1Input();	//fbaa
			} while ($12 == 0);
			createCommandWindow();	//$9a69();
		}
$992d:
		a = $7ed8 & #20;
		if (a != 0) { //beq $993a;
			fireCannon();	//$a50b();
			goto getCommandInput;	//$986c;
		}
$993a:
		if ($78ba < 0) return; //bpl 9940
	}
$9940:
	call_2e_9d53(a = 2);	//$3f:fa0e();指示するキャラが前にでる
	$53 = $52;
	$1a = $24 = $25 = $55 = 0;
	loadAndInitCursorPos(type:$55 = 0, dest:$1a = 0); //$34:8966();
$9958:	
	push (a = x);	//x = spriteOffset
	for (x = 3;x != 0;x--) {
		waitNmi();	//$3f:fb80();
	}
$9962:
	x = pop a; //= ($1a << 4)
	$1b = 0;
	$46 = 3;
	getInputAndUpdateCursorWithSound();	//$34:899e();
$996f:	//$23 = 選択コマンド位置
	if (1 != (a = $50)) {
		if (a == 0x40) {
			if (0 == (a = $24)) {
				$24++;
				$25 = 0;
				goto $9958;
			}
$9985:
			if (0 != (a = ($78ba & 0x8)) ) {
				a = 5;
			}
$9990:			else {
				a = 4;
			}
			$23 = a;
		} else {
$9996:
			if (a == 0x80) {
				if (0 == (a = $25)) {
					$25++;
					$24 = 0;
					goto $9958;
				}
$99a6:
				if (0 != (a = ($78ba & 0x8)) ) {
					a = 4;
				}
$99b1:				else {
					a = 5;
				}
				$23 = a;
			} else {
$99b7:
				if (a != 0x2) goto $9958;
				if (0 != $52) {
					$34:9a42();
				}
$99c2:
				a = 1;
				goto $99fd;
			}
		}
	}
$99c6:
	//$23: 選択コマンド(ウインドウ上からの番号,前進=4,後退=5)
	setSoundEffect05();	//set$ca_05_and_increment_$c9();	//$34:9b7d();
	init4SpritesAt$0220(index:$18 = 0); //$34:8adf();
	
	//a = $23; x = $52;
	//$7ac3.x = a;
	//x = $23;
	//a = $7400.x;
	//x = $52
	//$78cf.x = a;
	$7ac3[$52] = $23;
	a = $78cf[$52] = $7400[$23];	//listIndex => actionId

	$18 = #$9a16 + (a << 1);	//$34:9a16 : functionTable
	//y = 0;
	//a = $18[y];
	//push a; y++;
	//$19 = a = $18[y];
	$18 = *$18;
	(*$18)();	//jmp funcPtr
$99fd: //getCommandInput_next
	push a;
	push (a = $52);
	$52 = $53;
	call_2d9e53(a = #1);//$3f:fa0e(); 入力完了したキャラが下がる
	$52 = pop a;
	pop a;	//a: draw enemy window ?
	if (a != 0) goto $986f;
	else goto getCommandInput;	//$986c;
$9a16:	//jump table (for command)
}
```



