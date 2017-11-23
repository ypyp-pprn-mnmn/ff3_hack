
# $3e:de0f loadPatternToVramEx


### args:
+	[in] u8 a : vramAddrHigh (low=00)

### code:
```js
{
	bit $2002;
	$2006 = a; $2006 = 0;
}
```


**fall through**

