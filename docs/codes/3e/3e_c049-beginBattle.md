
# $3e:c049 beginBattle


### args:
+	[in] $6a : encounter id
+	[in] $6b : background view (00-step 01-sand 07-mountain)
+	[in] $78 : world (00:"floating land")

### notes:
least value of S = $1c = $20 - 4

### code:
```js
{
	switchToBank3C();	//$c98a();
	$bc12();
	a = $6a;
	x = $6b;
	y = $78;
	call_doBattle();	//$f800();
	//carry = player party lost
	if (carry) { //bcc c05d
		return $c000();
	} else {
		switchToBank3C();	//$c98a();
		return $bc2d();
	}
}
```




