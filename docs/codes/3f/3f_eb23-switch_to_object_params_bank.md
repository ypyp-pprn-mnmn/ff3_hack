
# $3f:eb23 switch_to_object_params_bank


## notes:
bank $2c stores various parameters for map objects, such as:
-	$2c:8000:	table of offsets (from $2c:8000) to object placement definitions
-	$2c:8200:	table of offsets (from $2c:8000) to event script 
-	$2c:8600:	table of offsets (from $2c:8000) to event parameters
	
see also $3f:ea04 floor::loadEventScriptStream.

## code:
```js
{
	return call_switch_2pages(a = 0x2c);	//jmp $ff03
}
```




