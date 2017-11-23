
# $35:a30f getIndexOfGreatest



### args:
+ [in] u16 $1a[4] : values
+ [in] u8 $24[8] : associated indices
+ [out] u8 $52 : index
+ [out] u8 x : index
+ [out] u8 $5f : offset to player of result index 

### notes:

### (pseudo-)code:

#### logic:
	for (var i = 1;i < 4;i++) {
		var val = values[i];
		if ( val > values[0] ) {
			values[i] = values[0];
			values[0] = val;
			var index = indices[i];
			indices[i] = indices[0];
			indices[0] = index;
		}
	}
```js
{
	y = 0; x = 2;
	for (x = 2;x != 8; x+=2 ) {
		if ( ($1a.y,$1b.y - $1a.x,$1a.x) < 0) { //bcs a344
			xchg( $1a.x, $1a.y); //push ($1a.x); $1a.x = $1a.y; $1a.y = pop a;
			xchg( $1b.x, $1b.y); //push ($1b.x); $1b.x = $1b.y; $1b.y = pop a;
			xchg( $24.y, $24.x);
		}
$a344:
	}
	x = $52 = $24 >> 1;
	return updatePlayerOffset(player:$52 );	//$a541();
$a353:
}
```



