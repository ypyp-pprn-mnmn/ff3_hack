
# $3c:9ebc menu.items.on_close
> アイテムウインドウを閉じる。

### args:
none.

### callers:
+	$3c:9ec2 menu.items.main_loop

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    jsr menu.accept_input_action    ; 9EBC 20 74 8F
    jmp menu.main.erase             ; 9EBF 4C 85 A6
*/
}
```

