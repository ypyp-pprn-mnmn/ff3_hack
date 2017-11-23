
# $35:ac6f command_charge



>0F: ためる


### (pseudo-)code:
```js
{
	$78d7 = #48;	//actionName
	$78d5 = 1;	//commandListId
	y = 1;
	a = $6e[y] & #28;	//蛙or小人
	if (a == 0) {	//bne $acca
		y = #27;
		a = $6e[y] + 1;
		if (a >= 3) {	//bcc $acc2;
			//ためすぎ
			$6e[y] = 0;
			$6e[3,4] >>= 1;	//currentHp >>= 1
			if ($6e[3,4] == 0) { //bne $acb7;
$acaa:				//HP1だった(自爆で死亡)
				getActor2C();	//$35:a42e
				x = (a & 7) << 1;
				$f0.x |= #80;	//dead
			}
$acb7:			$7e93 = 1;
			$78da = #2f;	//message "ためすぎてじばくした!"
			return;
		}
$acc2:			
		$6e[y] = a;
		$7e93 = 0;
		return;
	}
$acca:	//蛙か小人
	$78da = #3b;	//message "こうかがなかった"
	return;
}
```



