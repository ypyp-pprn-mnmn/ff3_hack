
# $3d:aa4b menu.await_new_input
> (新しい)何らかのパッド入力があるまで待つ。このロジックを呼び出す前に行われていた入力は有効とみなされない。

### args:
none.

### callers:
+	yet to be investigated

### local variables:
+	u8 $20: raw input bits.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
.L_AA4B:
    jsr menu.await_nmi_with_sound   ; AA4B 20 60 AA
    jsr field.get_input             ; AA4E 20 81 D2
    lda <$20     ; AA51 A5 20
    bne .L_AA4B   ; AA53 D0 F6
.L_AA55:
    jsr menu.await_nmi_with_sound   ; AA55 20 60 AA
    jsr field.get_input             ; AA58 20 81 D2
    lda <$20     ; AA5B A5 20
    beq .L_AA55   ; AA5D F0 F6
    rts             ; AA5F 60
*/
$aa60:
}
```

