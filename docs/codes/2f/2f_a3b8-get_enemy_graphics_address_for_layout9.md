
# $2f:a3b8 get_enemy_graphics_address_for_layout9()

### args:

#### in
+	x               : group_index * 2
+	u8 $86          : group_index
+	u16[?] $9068    : offsets (in per 8x8pixel tiles)

#### out
+  u16 $7e : source_addr
+  u16 $80 : dest_vram_addr (= 0x0700)
+  u8  $82 : length (= 0x90 (= 0x0c * 0x0c))
+  u8  $84 : source_bank
+  u8  y   : enemy_graphics_id * 2

### code:
```js
{
}
```


