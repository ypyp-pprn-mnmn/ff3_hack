
# $3d:a2df checkmagic


### (pseudo)code:
```js
{
	a = $a20c,y //y=magicid (00-37)
	$80 = a //a=flagMask
	a = $a244,y
	$7f = a //a=flagIndex

	x = $3d:a27c,y
	y = $7c00,x

	$7c00,x = itemid of magic
}
```



