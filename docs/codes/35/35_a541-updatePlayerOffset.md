
# $35:a541 updatePlayerOffset



### args:
+ [in] u8 $52 : playerIndexs
+ [out] u8 $5f : offset
+ [out] u8 A : offset

### (pseudo-)code:
```js
{
	//a = $52; 
	//$3f:fd3c();//a <<= 6
	//$5f = a;
	$5f = $52 << 6;
}
```



