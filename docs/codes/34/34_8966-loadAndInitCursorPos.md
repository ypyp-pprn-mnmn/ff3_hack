
# $34:8966 loadAndInitCursorPos



### args:
+ [in] u8 $1a : destIndex (spriteIndex)
+ [in] u8 $55 : cursorPositioningType
+ [in] u16 $34:8afa(file:68b0a) : initCursorParamPtrs { right,top }
+ [out] u8 $22,23,0050,0051 : 0
+ [out] u8 $0220+(destIndex*4) : cursorSprites
+ [out] u8 X : destOffset

### (pseudo-)code:
```js
{
	$55,56 = #8afa + ($55 << 1);
	push (a = $55[y = 0] );
	$56 = $55[++y]; $55 = pop a;
	$22,$23,$0050,$0051 = 0;

	loadCursorSprites();	//$34:8902();

	y = 0;
	$1c = $55[y++];
	$1d = $55[y];
	return tileSprites2x2(dest:$1a, top:$1c, right:$1d);	//jmp $892e
}
```



