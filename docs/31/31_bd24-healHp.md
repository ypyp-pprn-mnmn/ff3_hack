
# $31:bd24 healHp

<summary></summary>

## args:
+ [in,out] u16 $78,79 : [in] healAmount [out] actuallyHealedAmount
+ [in] ptr $24 : healTarget
## (pseudo-)code:
```js
{
	$1a,1b = $24[3,4];
	$24[3,4] += $78,79
	$18,19 = $24[5,6];
	if ($24[5,6] - $24[3,4] < 0) { bcs bd66
$bd4f:
		$24[3,4] = $18,19;
		$78,79 = $24[3,4] - $1a,1b;	//maxHP - hpBeforeHeal
	}
$bd66:
	return;
}
```



