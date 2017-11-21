
# $31:a2ba cacheStatus

<summary></summary>

## args:
+ [in] u16 $6e : actorPtr?
+ [in] u16 $70 : targetPtr?
+ [out] u8 $(e0+id*2)[2] : status of $70
+ [out] u8 $(f0+id*2)[2] : status of $6e
+ [out] u8 $62 : ? ($6e.#2c & 7) * 2
+ [out] u8 $64 : ? ($70.#2c & 7) * 2
+ [out] u8 $66 : $6e.#2c & 7)
+ [out] u8 $68 : $70.#2c & 7)
## (pseudo-)code:
```js
{
	$66 = a = getActor2C() & 7;
	$62 = a << 1; //battleCharIndex*2
	$68 = a = $70[y] & 7;
	$64 = a << 1;

	$f0.(x = $62) = $6e[1,2]
	$e0.(x = $64) = $70[1,2];
}
```



