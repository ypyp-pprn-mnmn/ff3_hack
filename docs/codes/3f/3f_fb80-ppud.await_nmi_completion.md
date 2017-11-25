


# $3f:fb80 ppud.await_nmi_completion

### args:
-	in,out u8 $05: pending_nmi
	-	0: no pending nmi operation (cleared by nmi handler)
	-	otherwise: pending nmi completion

### notes:
$05 is set by `$3f:fb57 ppud.nmi_handler`

### code:
```js
{
	$05++;
	while ($05 != 0) {}	//$05 will be set to 0 once nmi handler completed its operation
	return;
}
```





