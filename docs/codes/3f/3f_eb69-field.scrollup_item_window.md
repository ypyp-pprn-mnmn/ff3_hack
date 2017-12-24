# $3f:eb69 field.scrollup_item_window

### args:
+	[in,out] ptr $1c: pointer to text
+	[in] u8 $93: bank number of the text
+	in u8 $a3: cursor availability flags (of menu window #2)
+	[out] u8 $b4: ? (= 0xc0 if scrolled, or 0x80 if aborted)
+	in,out u8 $79f0: byte offset of selected menu-item (of menu window #2)
+   in,out u8 $79f2: ?
+	[out] bool carry: 1: scroll aborted, 0: scroll successful

### callers:
+	`1E:9233:20 69 EB  JSR field.scrollup_item_window` @ ?

### code:
```js
{
/*
 1F:EB69:A5 1C     LDA $001C = #$FA
 1F:EB6B:38        SEC
 1F:EB6C:E9 02     SBC #$02
 1F:EB6E:85 1C     STA $001C = #$FA
 1F:EB70:A5 1D     LDA $001D = #$85
 1F:EB72:E9 00     SBC #$00
 1F:EB74:85 1D     STA $001D = #$85
 1F:EB76:A5 93     LDA field.window_text_bank = #$1B
 1F:EB78:20 03 FF  JSR call_switch_2banks
 1F:EB7B:A0 01     LDY #$01
 1F:EB7D:B1 1C     LDA ($1C),Y @ $85FB = #$00
 1F:EB7F:F0 21     BEQ $EBA2
 1F:EB81:20 D1 EB  JSR field.unseek_to_line_beginning
 1F:EB84:A9 C0     LDA #$C0
 1F:EB86:85 B4     STA $00B4 = #$80
 1F:EB88:A5 A3     LDA $00A3 = #$00
 1F:EB8A:C9 02     CMP #$02
 1F:EB8C:D0 11     BNE $EB9F
 1F:EB8E:AD F0 79  LDA $79F0 = #$00
 1F:EB91:18        CLC
 1F:EB92:69 08     ADC #$08
 1F:EB94:8D F0 79  STA $79F0 = #$00
 1F:EB97:AD F2 79  LDA $79F2 = #$1E
 1F:EB9A:69 00     ADC #$00
 1F:EB9C:8D F2 79  STA $79F2 = #$1E
 1F:EB9F:4C 61 EB  JMP field.reflect_item_window_scroll
 1F:EBA2:A9 80     LDA #$80
 1F:EBA4:85 B4     STA $00B4 = #$80
 1F:EBA6:4C 3C EB  JMP field.abort_item_window_scroll
*/
}
```
