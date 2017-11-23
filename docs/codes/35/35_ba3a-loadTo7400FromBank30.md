
# $35:ba3a loadTo7400FromBank30



//(bank=$30)

### args:
+ [in] $1a : itemDataSize
+ [in] $18 : itemid (if magic,itemid-#$30)
+ [in] x : destOffset

### (pseudo-)code:
```js
{
	return loadTo7400Ex(bank:a = #18,restore:y = #1a);
}
```



