
# $31:be9d calcDataAddress

<summary>battleFunction07</summary>

## args:
+ [in] u8 $18 size (in bytes)
+ [in] u8 $1a index	
+ [in] u16 $20 baseAddr 
+ [out] u16 $1c dataAddr
## (pseudo-)code:
```js
{
	$1c = $20 + $18*$1a
}
```




