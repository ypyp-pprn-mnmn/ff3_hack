
# $3f:ed02 field::draw_window_box


## args:
### in:
+	u8 $37 : in_menu_mode (1: yes; skip some initializations)
### out:
+	u8 $38 : window_left (in 8x8 tile unit)
+	u8 $39 : window_top
+	u8 $3a : offset_x (or column in drawing)
+	u8 $3b : offset_y (or row in drawing)
+	u8 $3c : window_width (border excl.)
+	u8 $3d : window_height (border excl.)
## callers:
+	$3c:8efd
+	$3c:8f0e
+	$3c:8fd5
+	$3c:90b1
+	$3d:aaf4 (jmp)
## code:
```js
{
	x = $96;
	$ed61();	//get_window_metrics
	$3b = $39;
	$f670();	//field_calc_draw_width_and_init_window_tile_buffer
	field::fill_07c0_ff();	//$ed56
	push ( $3d - 2 );
	field::getWindowTilesForTop();	//$edf6();
	field::drawWindowLine();	//$edc6();
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
				field::drawWindowLine();	//$edc6();
				a = pop a - 2;
				if (a == 0) goto $ed3b
			} while (a >= 0); //bcs ed2a
$ed39:
			$3b--;
		}
	}
$ed3b:
	field::getWindowTilesForBottom()//$ee3e();
	field::drawWindowLine();	//$edc6();
$ed41:
	$38++; $39++;
	$3c -= 2;
	$3d -= 2;
	return restoreBanksBy$57();	//jmp $ecf5();
$ed56:
}
```



