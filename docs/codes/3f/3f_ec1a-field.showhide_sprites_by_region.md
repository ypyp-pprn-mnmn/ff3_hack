
# $3f:ec1a field::showhide_sprites_by_region


## args:
+	[in]	u8 A: show/hide.
	+	1: show
	+	0: hide
+	[in]	u8 X: region_type (0..6; with 0 to 4 being shared with window_type)
## callers:
+	$3f:ec0c field::show_sprites_on_lower_half_screen
+	$3f:ec12 field::show_sprites_on_region7 (with X set to 7)
+	$3f:ec18 field::showhide_sprites_by_window_region
## local variables:
+	u8 $80: region boundary in pixels, left, inclusive.
+	u8 $81: region boundary in pixels, right, exclusive.
+	u8 $82: region boundary in pixels, top, inclusive.
+	u8 $83: region boundary in pixels, bottom, exclusive.
+	u8 $84: show/hide flag
## notes:
-	"サロニア その1" (floor_id: $07) would be convenient location
	to test this function as there are various objects and floor levels.

	![The below is capturing a sprite that is about to cross window's boundary](images/sprite-and-window.png)
-	region_type 7 (i.e., 8th entry) seems to be INVALID.
	Static data referred to by this function consists of
	4 parallel arrays, of which has only 7 entries in each.
## code:
```js
{
/*
 1F:EC1A:85 84     STA $0084 = #$07
 1F:EC1C:BD 67 EC  LDA $EC67,X @ $ECE7 = #$85
 1F:EC1F:85 80     STA $0080 = #$2A
 1F:EC21:BD 6E EC  LDA $EC6E,X @ $ECEE = #$ED
 1F:EC24:85 81     STA $0081 = #$B4
 1F:EC26:BD 75 EC  LDA $EC75,X @ field::restore_bank = #$A5
 1F:EC29:85 82     STA $0082 = #$60
 1F:EC2B:BD 7C EC  LDA $EC7C,X @ $ECFC = #$A9
 1F:EC2E:85 83     STA $0083 = #$A3
 1F:EC30:A0 40     LDY #$40
 1F:EC32:B9 03 02  LDA sprite_buffer.x,Y @ $0283 = #$40
 1F:EC35:C5 80     CMP $0080 = #$2A
 1F:EC37:90 26     BCC $EC5F
 1F:EC39:C5 81     CMP $0081 = #$B4
 1F:EC3B:B0 22     BCS $EC5F
 1F:EC3D:B9 00 02  LDA sprite_buffer.y,Y @ $0280 = #$1C
 1F:EC40:C5 82     CMP $0082 = #$60
 1F:EC42:90 1B     BCC $EC5F
 1F:EC44:C5 83     CMP $0083 = #$A3
 1F:EC46:B0 17     BCS $EC5F
 1F:EC48:A5 84     LDA $0084 = #$07
 1F:EC4A:D0 0B     BNE $EC57
 1F:EC4C:B9 02 02  LDA sprite_buffer.attr,Y @ $0282 = #$02
 1F:EC4F:09 20     ORA #$20	;bit5 <- 1(: behind BG)
 1F:EC51:99 02 02  STA sprite_buffer.attr,Y @ $0282 = #$02
 1F:EC54:4C 5F EC  JMP $EC5F
 1F:EC57:B9 02 02  LDA sprite_buffer.attr,Y @ $0282 = #$02
 1F:EC5A:29 DF     AND #$DF	;bit5 <- 0(: in front of BG)
 1F:EC5C:99 02 02  STA sprite_buffer.attr,Y @ $0282 = #$02
 1F:EC5F:98        TYA
 1F:EC60:18        CLC
 1F:EC61:69 04     ADC #$04
 1F:EC63:A8        TAY
 1F:EC64:90 CC     BCC $EC32
 1F:EC66:60        RTS
*/
$ec67:
}
```



