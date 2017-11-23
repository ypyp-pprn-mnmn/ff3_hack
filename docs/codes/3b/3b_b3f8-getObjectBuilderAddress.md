
# $3b:b3f8 getObjectBuilderAddress


## args:
+	[in] u8 $86 : = ObjectParam.+03
+	[out] a,x = 
	+	$86 == 0 : #b43a
	+	$86 == 1 : #b44a
	+	$86 == 2 : #b42a
	+	$86 == 3 : #b41a
## (pseudo)code:
```js
{
	switch ( $86 & #03) {
	case 0: //beq b410
		a = #b4; x = #3a; return;
	case 1: //cmp #01 beq b415
$b415:
		a = #b4, x = #4a; return;
	case 2: //cmp #02 beq b40b
$b40b:
		a = #b4; x = #2a; return;
	default:
$b406:
		a = #b4; x = #1a; return;
	}
}
```



