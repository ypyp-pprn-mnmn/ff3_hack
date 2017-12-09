

# $3f:ed02 field.draw_window_box
> IDで指定されたウインドウの枠を描画し、その背景を空白で埋める。

### args:

#### in:
+	u8 $37 : in_menu_mode (1: yes; skip some initializations)
+	u8 $96 : window_type (only effective if $37 == 0)

#### in/out:
if $37 == 1, caller must supply all of the values listed in this secion as with border included.
on exit, these values have adjusted to exclude borders.

+	u8 $38 : window_left (in 8x8 tile unit)
+	u8 $39 : window_top
+	u8 $3c : window_width (border excl.)
+	u8 $3d : window_height (border excl.)

#### local variables:
+	u8 $3a : offset_x (or column in drawing)
+	u8 $3b : offset_y (or row in drawing)

### callers:
+	`1E:8EFD:20 02 ED  JSR field::draw_window_box`	@ $3c:8ef5 ?; window_type = 0
+	`1E:8F0E:20 02 ED  JSR field::draw_window_box`	@ $3c:8f04 ?; window_type = 1
+	`1E:8FD5:20 02 ED  JSR field::draw_window_box`	@ $3c:8fd1 ?; window_type = 3
+	`1E:90B1:20 02 ED  JSR field::draw_window_box`	@ $3c:90ad ?; window_type = 2
+	`1E:AAF4:4C 02 ED  JMP field::draw_window_box`	@ $3d:aaf1 field::draw_menu_window_box
+	(by falling through) @$3f:ecfa field::draw_in_place_window

### notes:
This logic plays key role in drawing window,
both for menu windows and in-place (rendered directly on top of floor maps) windows.
Usually window drawing is performed as follows:

1.	Call this logic to fill in background with window parts
	and setup BG attributes if necessary (the in-palce window case).
	In cases of the menu window, BG attributes have alreday been setup in another logic
	and should not be changed.

2.	Subsequently call other drawing logics which overwrites background with
	contents (aka "text") in the window, in 1 frame per 2 consecutive window rows,
	which is equivalent to 1 text line.
	These logics rely on window metrics variables, which is initially setup on this logic,
	and they don't change BG attributes anyway.

In the scope of this logic, it is safe to use the address range $0780-$07ff (inclusive) in a destructive way.
The original code uses this area as temporary buffer for rendering purporses
and discards its contents on exit.
More specifically, addresses are utilized as follows:

- $0780-$07bf: used for PPU name table buffer,
- $07c0-$07cf: used for PPU attr table buffer,
- $07d0-$07ff: used for 3-tuple of array that in each entry defines (vram address(high&low), value to tranfer)

### code:
```js
{
	x = $96;
	field.get_window_region();	//$ed61
	$3b = $39;
	$f670();	//field_calc_draw_width_and_init_window_tile_buffer
	field.init_window_attr_buffer();	//$ed56
	push( $3d - 2 );
	field::getWindowTilesForTop();	//$edf6();
	field.draw_window_row();	//$edc6();
	a = pop - 2;
	if (a != 0) { //beq ed3b
$ed23:
		if (a < 0) { //bcs ed2a
$ed25:
			$3b--;
			//jmp $ed3b
		} else {
$ed2a:
			do {
				push a;
				field::getWindowTilesForMiddle();	//$ee1d();
				field.draw_window_row();	//$edc6();
				a = pop a - 2;
				if (a == 0) goto $ed3b
			} while (a >= 0); //bcs ed2a
$ed39:
			$3b--;
		}
	}
$ed3b:
	field::getWindowTilesForBottom()//$ee3e();
	field.draw_window_row();	//$edc6();
$ed41:
	$38++; $39++;
	$3c -= 2;
	$3d -= 2;
	return field.restore_banks();	//jmp $ecf5();
$ed56:
}
```




