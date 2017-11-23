
# $3a:91c8 floor::getDynamicChip


## args:
+	[in,out] a : chipId
+	[out] $0500[ allocatedChipId ] : serial number 
+	$921f(7521f) : チップ分類

		00 00 00 00 04 04 04 04  04 04 04 04 04 04 04 04
		01 01 01 01 01 01 01 01  02 02 02 02 04 04 04 04
+	$923f: チップに割り当てるIDのベース値
		(割り当てるのはベース+同IDチップ内における順番)

		f0 f4 f8 fc 00 00 00 00  00 00 00 00 00 00 00 00
		80 90 a0 b0 c0 c4 c8 cc  e0 e4 e8 ec d0 00 00 00
## (pseudo)code:
```js
{
	x = a - #60;
	$88 = $0740.x; $0740.x++; //特定IDのチップの数
	y = $921f.x;
	$89 = $0760.y;	//特定の分類のチップの数
	$0760.y += 1;
	y = $923f.x + $88;
	if (x != #1c) {//beq 91f7
$91ed:
		$0500.y |= $89;	//y:allocated chipId => $89:serial number of chip that belongs to same category
		a = y;
		return;
	}
$91f7:
	push (a = y);
	x = $89;
	push (a = $0710.x);	//treasureId (0x000-1FF) 
	x = a & 7;
	y = pop a >> 3;
	if ( $78 != 0) { //beq 9210
		//下の世界
		y += #20;
	}
$9210:
	temp = ($925f.x & $6040.y);	//925f: 01 02 04 08 10 20 40 80
	y = pop a;	//= 923f.(chipId - #60) + $0740.(chipId - #60)
	if (temp >= 1) $91ed;
$921c:
	a = #7d;	//空箱
	return;
$921f:
}
```



