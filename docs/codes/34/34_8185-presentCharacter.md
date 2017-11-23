
# $34:8185 presentCharacter

<summary></summary>

## (pseudo-)code:
```js
{
	push a;	push (a = y); push (a = x);
	if ( 0 != (a = $7cf3)) {
		call_2e_9d53(a = #13);	//$3f:fa0e
		updatePpuDmaScrollSyncNmi();	//$3f:f8c5();
	}
$8197:
	x = pop a; y = pop a; pop a;
}
```



