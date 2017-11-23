
# $3e:cab1 field::merge_bg_attributes_with_buffer


### args:
+	[in] u8 $2d : ??? (1 if caller is: $3e:c98f field::update_window_attr_buff)
+	[in] u8 $30 : tile.y (in 16x16) (== $3b >> 1)
+	[in] u8 $31 : tile.x (in 16x16) (== $38 >> 1)
+	[in] u8 $86 : width (in 16x16)  (== $3c >> 1)
+	[in] u8 $07c0[0x10] : colorId to set 
+	[in,out] u8 $0300[0x80] : attrtable cache
+	[out] u8 $07d0[0x10] : vram addr high
+	[out] u8 $07e0[0x10] : vram addr low
+	[out] u8 $07f0[0x10] : attr value

### code:
```js
{
	push ($31);
	push ($30);
	y = 0;
$cab9:
	a = $30 >> 1; //tile.y
	x = #0f;
	if (carry) { //bcc cac2
		x = #f0;
	}
	$80 = a << 3; //tile.y >> 1 << 3
	$81 = x; //palette mask for vertical
	a = $31; //offset x
	x = #23;	
	if (a >= #10) { //bcc cad5
		a &= #0f;
		x = #27;
	}
$cad5:
	$82 = x; //vram high
	x = #33;
	a >>= 1; //offset x
	if (carry) { //bcc cade
		x = #cc;
	}
$cade:
	$80 |= a; //(tile.y >> 1 << 3) | (tile.x >> 1)
	$81 &= x; //vertical mask & horizontal mask
	$07d0.y = $82;	//vram high
	$07e0.y = $80 | #c0; //vram low
	$07f0.y = $81; //attr mask
	if (($2d & #02) == 0) { //bne cb0f
		$31 = ($31 + 1) & #1f;
		if (++y < $86) { bcs cb24
			goto $cab9;
		}
	} else {
$cb0f:
		if ((a = $30 + 1) >= #0f) { //bcc cb1a
			a -= #0f;
		}
$cb1a:
		$30 = a;
		if (++y < #0f) { //bcs cb24
			goto $cab9;
		}
	}
$cb24:
	$30 = pop a;
	$31 = pop a;
$cb2a:
	x = $86; x--;
	if (($2d & #02) != 0) { //beq cb34
		x--;
	}
$cb34:
	for (x;x >= 0;x--) {
		if ( ($07d0.x & #04) == 0) { //bne cb43
			//BG 00
			a = $07e0.x & #3f;
		} else {
$cb43:			//BG 01
			a = $07e0.x & #3f | #40;
		}
$cb4a:
		y = a;
		$0300.y = $07f0.x = (($0300.y ^ $07c0.x) & $07f0.x) ^ $0300.y;
	}
	return;
$cb61:
}
```




