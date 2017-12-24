

# $3c:912a menu.put_cursor_on_window2
> カーソルを2つ目のメニューウインドウ($7900で管理)の現在選択されている項目に配置する。

### args:
+	in u8 $a3: cursor availablity flags on window-2.
+	in u8 $79f0: byte offset of selected item (each menu item consists of 4-byte structure)
+	in MenuItem $7900[]: cursor stop

### callers:
+	$3c:a7cd menu.render_cursor

### local variables:
none.

### notes:
unlike the sibling logic for window-1 (controlled with $7800),
this logic checks some internal states before setting up the cursor.
the following windows are operated as 'window-2':

-	player characters to select target of magic/item
-	files on save/load menu
-	shop offerings
-	name display at new game

### (pseudo)code:
```js
{
/*
; ----------------------------------------------------------------------------
    lda <$A3     ; 912A A5 A3
    bne .L_912F   ; 912C D0 01
.L_912E:
  	rts             ; 912E 60
; ----------------------------------------------------------------------------
.L_912F:
  	cmp #$01    ; 912F C9 01
    beq .L_9140   ; 9131 F0 0D
    lda $79F2   ; 9133 AD F2 79
    bne .L_912E   ; 9136 D0 F6
    lda $79F0   ; 9138 AD F0 79
    cmp $79F1   ; 913B CD F1 79
    bcs .L_912E   ; 913E B0 EE
.L_9140:
  	ldy $79F0   ; 9140 AC F0 79
    ldx $7900,y ; 9143 BE 00 79
    lda $7901,y ; 9146 B9 01 79
    jmp .L_9164   ; 9149 4C 64 91
*/
}
```


