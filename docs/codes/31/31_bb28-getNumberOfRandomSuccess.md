
# $31:bb28 getNumberOfRandomSuccess



### args:
+ [in] u8 $24 : countToTry ?
+ [in] u8 $25 : percentSuccess
+ [out] u8 $30 : resultCount
+ [out] u8 A : resultCount

### (pseudo-)code:
```js
{
	$30 = 0;
	for ($24;$24 != 0;$24--) {
		getRandom(#63);//$31:beb4
		if (a < $25) { //bcs $bb3b
			$30++;
		}
$bb3b:
	}
	return $30;
}
```



