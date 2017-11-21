
# $3f:e917 floor::processChipEvent


## args:
+	[in] u8 $49 : warpparam.+01 & 0x20
+	[out] bool carry : event fired (1=yes)
+	[out] u8 a : message id?
## code:
```js
{
	floor::getChipEvent();	//$e51c();
	if ($44 < 0) { //bpl e95e
		a = y;	//y: chipId
		if (a < #90) e95e;
		if (a < #a0) e968;
		if (a < #d0) e95e;
		if (a >= #f0) e95e;
$e92f:		//chipId:d0-ef
		$ba = x = 0;
		if (a < #e0) return OnTreasure(); //bcc e982
		
		//chipId:e0-ef
		$ba--;
		x = $45 & #0f;
		push (a = $0710.x);	//treasureId
		x = a & 7;
		y = a >> 3;
		if ($78 != 0) {	//78=world
			y += #20;
		}
$e953:
		if (($e960.x & $6040.y) == 0) return OnTreasure(); //$e982();
	}
$e95e:
	clc;
	return;
$e960:
	01 02 04 08 10 20 40 80
$e968:	//#90 <= chipId < #a0
	x = $600e; //先頭キャラオフセット?
	if ($6100.x; != #08) { //beq e976
	//job == thief
		a = #03;
		sec;
		return;
	}
$e976:
	$6021 |= #40;
	a = #7a;
	sec;
	return;
}
```




