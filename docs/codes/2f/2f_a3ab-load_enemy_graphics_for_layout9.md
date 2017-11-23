
# $2f:a3ab load_enemy_graphics_for_layout9()

### args:
+  [in] u8 $7d68    : spawn_param_id

### code:
```js
{
    a = $7d68 << 1;
    if ( a >= 0 ) { //bmi a3b7
        get_enemy_graphics_address_for_layout9();   //a3b8
        $a40b();
    }
$a3b7:
}
```


