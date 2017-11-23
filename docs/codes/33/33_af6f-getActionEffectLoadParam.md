
# $33:af6f getActionEffectLoadParam

### args:
+	[in] u8 $7e88 : actionId
+	[out] u8 $7e8b[3] : params <= $2e:91d0[actionId*3] 

### code:
```js
{
	mul8x8_reg(a = $7e88,x = 3);	//$3f:f8ea
	return memcpy(src:$7e,7f = #91d0 + (a,x), dest:$80,81 = #7e8b,
		len:$82 = 3, bank:$84 = #17); //$3f:f92f
}
```


