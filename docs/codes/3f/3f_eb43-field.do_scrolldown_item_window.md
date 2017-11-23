
# $3f$eb43 field.do_scrolldown_item_window


## args:
+	[out] bool carry: always 0. (= scroll successful)
## callers:
+	`1F:EB36:D0 0B     BNE field.scrolldown_item_window` @ $3f$eb2d field.scrolldown_item_window
## code:
```js
{
/*
 1F:EB43:A9 C0     LDA #$C0
 1F:EB45:85 B4     STA $00B4 = #$00
 1F:EB47:A5 A3     LDA $00A3 = #$00
 1F:EB49:C9 02     CMP #$02
 1F:EB4B:D0 11     BNE $EB5E
 1F:EB4D:AD F0 79  LDA $79F0 = #$00
 1F:EB50:38        SEC
 1F:EB51:E9 08     SBC #$08
 1F:EB53:8D F0 79  STA $79F0 = #$00
 1F:EB56:AD F2 79  LDA $79F2 = #$1E
 1F:EB59:E9 00     SBC #$00
 1F:EB5B:8D F2 79  STA $79F2 = #$1E
 1F:EB5E:20 A9 EB  JSR field::seek_to_next_line
*/
}
```


**fall through**

