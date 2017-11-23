
# $31:be98 setYtoOffsetOf



### args:
+ [in] u8 a : memberOffsetToSet
+ [in] u8 $5f : basePtr
+ [out] u8 a,y : resultOffsetFromBasePtr

### (pseudo-)code:
```js
{ 
	y = a + $5f;
}
```



