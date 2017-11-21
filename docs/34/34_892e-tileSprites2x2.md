
# $34:892e tileSprites2x2

<summary></summary>

## args:
+ [in] u8 $1a : spriteIndex
+ [in] u8 $1c : top
+ [in] u8 $1d : right
+ [out] u8 X : $1a << 4
+ [out] u8 $0220,$0223,$0224,$0227,$022b : ?
## (pseudo-)code:
```js
{
	x = $1a << 4; //fd3e()
	$0220.x = $1c;	//sprite[0].y
	$0223.x = $1d;	//sprite[0].x
$893e:	jmp $8941
$8941:
	x = $1a << 4; //fd3e()
	$0224.x = a = $0220.x;		//sprite[1].y = sprite[0].y
	a += 8;				
	$022c.x = $0228.x = a;		//sprite[2].y sprite[3].y
	$022b.x = a = $0223.x;		//sprite[2].x = sprite[0].x
	a -= 8;	
	$0227.x = $022f.x = a;		//sprite[1].x sprite[3].x
}
```



