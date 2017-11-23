
# $3e:cb6b field::copyToVramWith_07d0


## args:
+	[in] x : last entry (max = #0f)
## code:
```js
{
	$2002;
	for (x;x >= 0;x--) {
$cb6e:
		$2006 = $07d0.x;
		$2006 = $07e0.x;
		$2007 = $07f0.x;
	}
	return;
$cb84:
}
```




