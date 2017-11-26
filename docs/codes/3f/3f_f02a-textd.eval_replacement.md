


# $3f:f02a textd.eval_replacement


### args:
+	[in] a: charcode
+	[in] y: offset into the string pointed to by $3e.
+	[in, out] u8 $1f: number of lines drawn (in 8x8 unit)
+	[in] string * $3e: ptr to text to evaluate.
	On entry, this will point to the parameter byte of replacement code.
+	[in,out] u8 $67: ?
+	[in,out] u8 $90: offset into the tile buffer ($0780/$07a0)
+	[out] u8 $0780[32]: tile (or name table) buffer for upper line
+	[out] u8 $07a0[32]: tile (or name table) buffer for lower line

### local variables:
+	u8 $80,81,82,83: scratch.
+	u8 $84: parameter byte
+	u8 $97,98

### notes:
charcodes ranged [10...28) are defined as opcodes (or 'replacement'),
given that the codes have followed by additional one byte for parameter.

#### code meanings:
+	10-13: status of a player character. lower 2-bits represents an index of character.
+	15-17: left-align text by paramter,increment menu-item count by 4
+	1e: get job name

### code:
```js
{
	push a;
	x = $67;
	if (a != #1d) { //beq f034
		x = $3e[y];
	}
$f034:
	$67 = $84 = x;
	$3e,3f++;
	pop a;	//charcode
	if (a < #14) goto $f239; //bcs f046
$f046:
	if (a == #14) { //bne f04f
		$90 = $84;
		return textd.draw_in_box();	// field::decodeString();//jmp
	}
$f04f:
	if (a < #18) { //bcs f09b
		$81 = a - #15 + #78;
		$80 = 0;
		$90 = $84;
		$82 = $3e[y];
		$83 = $3e[++y];
		a = $80[y = #f1];	//78f1/79f1/7af1
		if ((x = $1e) == 0) { //bne f077
			$1e++;
			a = x;
		}
$f077:
		x = a;
		$80[y] = a + 4;
		y = a = x;
		$80[y] = $84 + $97;
$f086:
		$80[++y] = $98 + $1f;
		$80[++y] = $82;
		$80[++y] = $83;
		//tail recursion. equivalent to just go back to beginning of the loop.
		return textd.draw_in_box();	// field.eval_and_draw_string();	//jmp eefa
	}
$f09b:	//#18 <= a < #28
	if (a == #18) { //bne f0f0
		//...
	}
$f0f0:
	if (a == #19) {} //bne f114
$f114:
	if (a == #1a) {} //bne f128
$f128:
	if (a == #1b) {} //bne f13f
$f13f:
	if (a == #1c) {} //bne f14c
$f14c:
	if (a == #1d) {} //bne f17a
$f17a:
	if (a == #1e) { //bne f19a
$f17e:
		getLastValidJobId();	//$f38a
		if (a < $84) { //bcs $f192
			$78f1 -= #4;
			a = #ff;
			clc;
			return;
		}
$f192:
		a = $84 + #e2;
		return $f2d8();
	}
$f19a:
	if (a == #1f) {} //bne f1bb
}
```




