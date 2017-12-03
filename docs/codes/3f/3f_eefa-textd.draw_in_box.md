

# $3f:eefa textd.draw_in_box
> render a text in the specified box (i.e., window) by filling up the shared buffer (at $0780,07a0).

### args:
+	[out] bool carry: more_to_draw.
	- 1: reached bottom of the box without reaching end of the text
	- 0: reached end condition of the text.
+	[out] u8 A: exit condition. valid if and only if more_to_draw: 0.
	- 0xFF: terminated shop/job menu. (more_to_draw: 0)
	- 0x09: code 0x0a encountered. (more_to_draw: 0)
	- 0x00: code 0x00 (terminating null) encountered. (more_to_draw: 0)
+	[in, out] u8 $1e: continue building menu items (1: yes 0: restart)
+	[in, out] u8 $1f: number of lines drawn (in 8x8 unit)
+	[in, out] string* $3e: ptr to string. this pointer must be valid along with the text_bank ($93) mapped.
+	[in, out] u8 $67: offset to a particular player character? (TBC)
+	[in, out] u8 $90: output index
+	[in, out] ptr $99: temporary stack of text ptr ($3e)
+	[in, out] u8 $0780[32]: upper tile (i.e., name table index) buffer.
+	[in, out] u8 $07a0[32]: lower tile (i.e., name table index) buffer.
+	[in] $37: in_menu_mode (1: menu, 0: floor)
+	[in] $3d: box height (in 8x8 unit)
+	[in] u8 $93: text_bank. used to restore banks after temporary switch to another bank.
+	[in] u8 $97: box left (in 8x8 unit). used to calculate menu item's coordinates.
+	[in] u8 $98: bot top (in 8x8 unit). used to calculate menu item's coordinates.
+	[in] u8 $bb: treasure item id

### callers:
+	`1F:EEE4:20 FA EE  JSR field.eval_and_draw_string` @ $3f:eec0 field.draw_string_in_window

#### all the following are recursive calls (including tail call):
+	`1F:F0D8:20 FA EE  JSR field.eval_and_draw_string` @ $3f:f02a field.string.eval_replacement (recurse)
+	`1F:F33F:20 FA EE  JSR field.eval_and_draw_string` @ ?
+	`1F:EF24:4C FA EE  JMP field.eval_and_draw_string` @ $3f:eefa field.eval_and_draw_string (recurse)
+	`1F:F345:4C FA EE  JMP field.eval_and_draw_string` @ ?
+	`1F:F387:4C FA EE  JMP field.eval_and_draw_string` @ ?

### local variables:
+	u8 $80,81,82,83,85: scratch.
+	u8 $84: scratch, usually having a byte immediately following the code byte

### notes:
no cpu registers preserved across the call, and there is no dependency on state of A,X,Y on entry.
this somewhat large function is an entry point for individual handlers which process a particular charcter code.
As being consisting of many cases, this function is being quite large.
in some of those handlers, recursive calls are made to this function to 'replace' (or 'eval') embedded code.
however, as this function depends on many variables, callers must take care of them.


### code:
```js
{
$eefa:
	for (;;) {
		y = 0;
		if ((a = $3e[y]) == 0) {
			//beq $eef1.
$eef1:
			clc;	//reached end of string. no further rendering required.
			return;
		}

		if (++$3e == 0) { //bne ef06
$ef04:
			$3f++;
		}
$ef06:
		if (a >= 0x28) { //bcc $ef3e;
		//code represents printable character.
			if (a >= 0x5c) { bcc $ef27;
$ef0e:
				//#5c <= a
				y = $90;
				if ( ((x = $37) == 0) //bne ef1a
					&& (a < 0x70)) //bcs ef1a
				{
				//a := [5c,70) C,G,L,V,装備アイコン
$ef18:
					a = 0xff;	
				}
$ef1a:
				$07a0.y = a;
				$0780.y = 0xff;
				$90++;
			} else {
$ef27:				//#28 <= a < #5c : 濁音 or 半濁音
				x = a - #28;
				$0780.y = $f515.x;	//char code to tile index (upper row)
				$07a0.y = $f4e1.x;	//char code to tile index (lower row)
				$90++;
			}
			continue;	//jmp $eefa
		}
$ef3e:	//a < #28 (control code)
		if (a >= 0x10) { //bcc ef45
			//char code:= [0x10...0x28)
			return textd.eval_replacement(); //$f02a
		}
$ef45:
		swtich (a) {
		case 0x01:	//bne ef5b
			//01=\n
			field.draw_window_content();	//$f692();
			$1f++;
$ef4e:
			$1f++;
			if ($1f >= $3d) { //bcc ef58
				sec;	//reached window bottom with remaining string
				return;
			}
$ef58:
			break;	//jmp $eefa (just go back to beginning of the loop)
$ef5b:
		case 0x02: //bne ef6a
			$84 = $bb;
			$b9 = 0;
			return $f09d();
$ef6a:
		case 0x03:	//bne ef7c
			switch_to_character_logics_bank();	//$f727();
			$f5ca(X = $bb);
			$3c$8b78();
			/*
			1F:F291:A5 93     LDA field.window_text_bank = #$1B
 			1F:F293:20 03 FF  JSR call_switch_2banks
 			1F:F296:4C FA EE  JMP field.eval_and_draw_string
			*/
			return $f291();
$ef7c:
		case 0x04:	//bne ef95
			$80 = $61;
			$81 = $62;
			$82 = $63;
			switch_to_character_logics_bank();	//$f727();
			$3c$8b78();
			return $f291();
$ef95:
		case 0x05:	//bne efa2
			switch_to_character_logics_bank();	//$f727();
			$3c$8b03();
			return $f291();
$efa2:
		case 0x06:	//bne efa9
			break;	//jmp $eefa
$efa9:
		case 0x07:	//bne efbb
			if (0 == (a = $600b)) {
				break;	//bne $efa6
			}
			a += (-1 + 0xf8);
			return $f2d8();
$efbb:
		case 0x08:	//bne efda
			$80 = $601b;	//capacity?
			$81 = 0;
			switch_to_character_logics_bank();	//$f727();
			$3c$8b57();
			x = $90++;
			$07a0.x = 0x5c;	//'C'
			return $f291();
$efda:
		case 0x09:	//bne efe4
			field.draw_window_content();	//$f692
			return $ef4e();	//in this function.
$efe4:
		case 0x0a:	//bne efec
			a = 0x09;
			return;
$efec:
		case 0x0b:	//bne eff0
			//fall through.
$eff0:
		case 0x0c:	//bne effa
			x = $600e;
			return $f316();
$effa:
		case 0x0d:	//bne f007
			switch_to_character_logics_bank();	//$f727();
			$3c$8B34();
			return $f291();
$f007:
		case 0x0f:	//bne f027 note: 0xF. not 0xE.
			x = $90;
			$0780.x = a = 0x58;	// ごみばこ(左上)
			$07a0.x = a = 0x59;	// ごみばこ(左下)
			$0781.x = a = 0x5a; // ごみばこ(右上)
			$07a1.x = a = 0x5b; // ごみばこ(右下)
			$90 = (a = x) + 2;
$f027:
		default:
			break;	//jmp $eefa (just go back to beginning of the loop)
	}	//parse loop
}
$f02a:
```






