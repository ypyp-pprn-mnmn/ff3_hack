
# $3f:eb2d field.scrolldown_item_window


## args:
+	[in,out] ptr $1c: pointer to text
+	[in,out] ptr $3e: pointer to text
+	[in] u8 $93: bank number of the text
+	[in] u8 $a3: ?
+	[out] u8 $b4: ? (= 0x40(if aborted) or 0xC0(if scrolled))
+	[in,out] u16 ($79f0,$79f2): ?
+	[out] bool carry: 1: scroll aborted, 0: otherwise
## callers:
+	`1E:9255:20 2D EB  JSR field.scrolldown_item_window` @ ?
## code:
```js
{
/*
 1F:EB2D:A0 00     LDY #$00
 1F:EB2F:A5 93     LDA field.window_text_bank = #$1B
 1F:EB31:20 03 FF  JSR call_switch_2banks
 1F:EB34:B1 3E     LDA ($3E),Y @ $86FB = #$17
 1F:EB36:D0 0B     BNE field.do_scrolldown_item_window
 1F:EB38:A9 40     LDA #$40
 1F:EB3A:85 B4     STA $00B4 = #$C0
*/
$eb3c:
}
```


**fall through**

