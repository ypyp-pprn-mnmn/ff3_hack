
# $2f:a42e get_enemy_pattern_address_and_copy_pattern_to_vram()

### notes:
(a,b) := lower bytes first.

### args:

#### in:
+	x:          group_index * 2
+	u8 $86:     group_index
+	enemy_graphics_params[4] $7d73: loaded_graphics_params
	+	graphics_id must be < 0xc0

### out
+  u16 $7e : source_addr
+  u16 $80 : dest_vram_addr
+  u8 $82 : size_flags
+  u8 $84 : source_bank
+  u8 $86: next_group_index
+  u8 $88 : enemy_graphics_id
+  u16 $8a : source_offset (from $a4b4)

### static references:
+  u16[4] $a4a4: group_index_to_dest_vram_addrs
+  u16[4] $a4ac: group_index_to_dest_vram_addrs (for enemies which have the flag's bit5-7 set)
+  [6] $a4b4: enemy_graphics_size_params { u16 offset, u8 bank, u8 size_index }
+  [7] $a4cc: enemy_graphics_sizes { u8 width, u8 height } // metrics in tiles

### code:
```js
{
    $88 = a = $7d73.x;
    y = (a & #e0) >> 3; // logically >> 5 << 2
    ($8a,8b,84) = ($a4b4,a4b5,a4b6)[y];
    y = [$a4b7][y] << 1;
    (a, x) = ($a4cc,a4cd)[y];       //a,x = width, height
    mul_8x8_reg(a,x);               //$3f:f8ea() width*height
    $82 = a;                        //lower 8bits of width($a4cc)*height($a4cd)
    ($18,19) = (a, x);              //$18,19 = (width * height) * 16
    ($18,19) <<= 4;                 //
    ($1a,1b) = ($88 & #1f, #00);    //$1a,1b = (graphics_index & 0x1f)
    mul_16x16();                    //$1c,1d = ($18,19)*($1a,1b)
    // source_addr =
    //      base_addr + ((width * height) * 16 * (graphics_index & 0x1f))
    //
    ($7e,7f) = ($1c,1d) + ($8a,8b); //$1c,1d: $18,19*$1a,1b
    x = $86 << 1;
    $86++;
    if ( 0 == ($88 & #e0) ) {
        // 4x4 tiles の場合
        x += 8;
    }
$a497:
    ($80,81) = ($a4a4,a4a5).x;
    return copy_to_vram_with_encounter_mode(); //$3f:f942();
}
```


