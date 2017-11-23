
# $2f:a38c load_enemy_pattern()

### args:
+	[preserved] x
+	[in] u8      x       : group_index
+	[in] u8[4]   $7d6b   : enemy_id
+	[in] u8      $7d7b   : enemy_graphics_layout_id

### code:
```js
{
    if ( $7d6b[group_index] == #ff ) {
        return;
    }
    x <<= 1;
    if ( $7d7b == #09 ) {
        load_enemy_graphics_for_layout9();  //$a3ab
    } else {
        get_enemy_pattern_address_and_copy_pattern_to_vram(x);  //$a42e
    }
    
}
```


