
# $34:9f87 setActionTargetToSelf //setActionTargetBitAndFlags

<summary></summary>

## args:
+ [in,out] $6e[#2f] : target indicator bits
+ u8 $fd24.x : bitmask for target
## (pseudo-)code:
```js
{
	push (a = getActor2C() );	//$a42e
	x = a = a & 7;
	flagTargetBit();	//$3f:fd20
	$7e99 = $7e9b = $6e[y = #2f] = a;
	a = pop & #80; y++;
	$6e[y] = a;
	return a = $6e[y = #2f];
$9fa8:
}
```



