
# $31:a397 isRangedWeapon



### args:
+ [in] u8 $741e : isDouble
+ [in] u8 $741f : countOfWeaponHand
+ [out] bool carry : ranged

### notes:
>竪琴フラグがどちらかの手に立っているか
>装備武器のidが3f,40,41ならtrue

### (pseudo-)code:
```js
{
	$52 = a & 7
	a = $6e[y = #31] | $6e[++y] & #08;	//08:竪琴フラグ
	if (a != 0) return true;

	y = updatePlayerOffset();	//$be90
	y += 3;
	$18 = $59[y]; y += 2;
	$19 = $59[y];
	if (($18 | $19) == 0) return false;	//beq $a3fb;
$a3bb:
	if ($741e == 0) { //bne a3de
		//二刀流でない
		if ( ((a = $18) != 0) //beq a3d2
			&& (a < #57) //bcs a3d2
		{
$a3c8:			//盾以外を右手に持っている
			if (a >= #42 || a < #3f) return false; //a3fb
			return true; //a3fe
		}
$a3d2:		//右手は盾か素手
		if ( (a = $19) >= #42 || a < #3f) return false; a3fb
		return true;
	}
$a3de:
	if ($741f == 2) { //bne a3f1
$a3e5:		//2=二刀流の最初の攻撃(=右手)
		if ((a = $18) >= #42 || a < #3f) return false;
		return true;
	}
$a3f1:
	if ((a = $19) >= #42 || a < #3f) return false;
$a3fb:
	return false;
$a3fe:
	return true;
}
```



