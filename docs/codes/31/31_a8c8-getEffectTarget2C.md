
# $31:a8c8 getEffectTarget2C


//or $24_2c

### (pseudo-)code:
```js
{
	return a = $24[y = #2c];
	//ldy	 #$2c
	//lda	[$24],y
	//rts
}
```



