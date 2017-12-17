
# $31:bb1c battle.push_damage_value_for_enemy_side
> 直前のダメージ計算結果を敵側の表示用として追加する

### args:

#### in:
+	u16 $78: damage value
+	u8 X: damage index

#### out:
+	u16 $7e5f: damage value

### callers:
+	$31:af77 battle.specials.execute

### local variables:
none.

### (pseudo)code:
```js
{
/*
	lda $78         ; BB1C A5 78
	sta $7E5F,x     ; BB1E 9D 5F 7E
	inx 			; BB21 E8
	lda $79         ; BB22 A5 79
	sta $7E5F,x     ; BB24 9D 5F 7E
	rts 			; BB27 60
*/
}
```

