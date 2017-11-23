
# $34:850a playEffect_09 //charge (command0F)



### args:
+ [in] u8 $7e93 : effectFlag (1=ためすぎ 0=通常)

### (pseudo-)code:
```js
{
	set52toActorIndexFromEffectBit();	//$8532
	a = $7e93 + #16;
	return call_2e_9d53(); //fa0e
}
```



