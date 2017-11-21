
# $3f$eb3c field.abort_item_window_scroll


## args:
+	[in] u8 $57: bank number to restore
+	[out] bool carry: always 1. (scroll aborted)
## callers:
+	`1F:EBA6:4C 3C EB  JMP field.abort_item_window_scroll` @ $3f$eb69 field.scrollup_item_window
## code:
```js
{
/*
 1F:EB3C:A5 57     LDA $0057 = #$3C
 1F:EB3E:20 03 FF  JSR call_switch_2banks
 1F:EB41:38        SEC
 1F:EB42:60        RTS
*/
$eb43:
}
```



