
# $3f:ecfa field::draw_in_place_window


### args:
+	[in] u8 A: window_type

### code:
```js
{
//1F:ECFA:85 96     STA window_id = #$00
//1F:ECFC:A9 00     LDA #$00
//1F:ECFE:85 24     STA $0024 = #$00
//1F:ED00:85 25     STA $0025 = #$00
}
```


**fall through**

