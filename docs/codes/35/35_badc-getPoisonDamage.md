
# $35:badc getPoisonDamage

<summary></summary>

## (pseudo-)code:
```js
{
	a = x = $28[y = #01];
	if ( ((a & #02) != 0) //beq bb3f
		&& ((x & #c0) == 0)) //bne bb3f
	{
		$64++;
		$62 = $24 << 1;
		$26 = $28[y = #05];
		$27 = $28[++y];
$bafc:
		$26,27 >>= 4;
		x = $62;	//index<<1
		$7400.x = $26; x++;
		$7400.x = $27;
	}
}
```




