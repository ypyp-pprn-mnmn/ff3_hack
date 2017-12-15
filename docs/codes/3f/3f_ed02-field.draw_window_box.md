


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
/*
    ldx <.window_type                   ; ED02 A6 96
    jsr field.get_window_region         ; ED04 20 61 ED
	lda <.window_top                    ; ED07 A5 39
	sta <.offset_y                      ; ED09 85 3B
	jsr field.calc_draw_width_and_init_window_tile_buffer; ED0B 20 70 F6
	jsr field.init_window_attr_buffer   ; ED0E 20 56 ED
	lda <.window_height                 ; ED11 A5 3D
	sec                                 ; ED13 38
	sbc #$02                            ; ED14 E9 02
	pha                                 ; ED16 48
	jsr field.get_window_top_tiles      ; ED17 20 F6 ED
	jsr field.draw_window_row           ; ED1A 20 C6 ED
	pla                                 ; ED1D 68
	sec                                 ; ED1E 38
	sbc #$02                            ; ED1F E9 02
	beq .render_bottom                  ; ED21 F0 18
	bcs .render_body                    ; ED23 B0 05
	dec <.offset_y                      ; ED25 C6 3B
	jmp .render_bottom                  ; ED27 4C 3B ED
.render_body:
	pha                                 ; ED2A 48
	jsr field.get_window_middle_tiles   ; ED2B 20 1D EE
	jsr field.draw_window_row           ; ED2E 20 C6 ED
	pla                                 ; ED31 68
	sec                                 ; ED32 38
	sbc #$02                            ; ED33 E9 02
	beq .render_bottom                  ; ED35 F0 04
	bcs .render_body                    ; ED37 B0 F1
	dec <.offset_y                      ; ED39 C6 3B
.render_bottom:
	jsr field.get_window_bottom_tiles   ; ED3B 20 3E EE
	jsr field.draw_window_row           ; ED3E 20 C6 ED
	inc <.window_left                   ; ED41 E6 38
	inc <.window_top                    ; ED43 E6 39
	lda <.window_width                  ; ED45 A5 3C
	sec                                 ; ED47 38
	sbc #$02                            ; ED48 E9 02
	sta <.window_width                  ; ED4A 85 3C
	lda <.window_height                 ; ED4C A5 3D
	sec                                 ; ED4E 38
	sbc #$02                            ; ED4F E9 02
	sta <.window_height                 ; ED51 85 3D
	jmp field.restore_banks             ; ED53 4C F5 EC
*/
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





