
# $3f:f942 copy_to_vram_with_encounter_mode


## code:
```js
{
    if ( $78c3 != 0x88 ) {
        return copyToVramDirect();
    }
    // バックアタックの場合は、ビットの並びを反転するための
    // 参照マップを作成する。
    for ( x = 0; x < 256; x++ ) {
        // for ( y = 8; y > 0; y-- ) {
        //      asl, ror $18
        // }
        $18 = reverse_bits_of(x);
        $7300.x = $18;
    }
    $92 = 1;    // 1: 参照マップを使用する
    return copyToVram();
}
```



