
# $3d:aa60 menu.await_nmi_with_sound
> 音楽の再生を行いつつ、次のNMIを待つ。

### args:
none.

### callers:
+	yet to be investigated

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    jsr thunk_await_nmi_by_set_handler  ; AA60 20 00 FF
    jsr field.call_sound_driver_and_restore_banks; AA63 20 58 C7
    rts             ; AA66 60
*/
$aa67:
}
```

