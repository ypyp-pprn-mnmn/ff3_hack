
# $35:b93e flagJob

<summary></summary>

## (pseudo-)code:
```js
{
+ [in] a=jobindex
	$3b,3c,3d = {0};
	sec
	for (x = jobindex;x>0;x--) {
		rol $3d
		rol $3c
		rol $3b
	}
	return;
$b953:
}
```



