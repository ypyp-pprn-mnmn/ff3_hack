
# $31:b921 clearEffectTargetIfMiss



### args:
+	[in] u8 $7c : hitCount
+	[in,out] u8 $7e9b : playEffectTargetBit
+	[in] u8 $7ec1 : targetIndex

### (pseudo-)code:
```js
{
	if ($007c == 0)  //bne b932
}
```


**fall through**

