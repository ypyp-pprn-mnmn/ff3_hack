
# $31:af63 addItemBonus

<summary></summary>

## args:
+ [in] u8 A : bonusFlag
+ [in,out] u8 $2c[5] : params
## (pseudo-)code:
```js
{
	for (x = 0;x != 5;x++) {
		a <<= 1;
		if (carry) {
			push a;
			$2c.x += 5;
			pop a;
		}
	}
}
```



