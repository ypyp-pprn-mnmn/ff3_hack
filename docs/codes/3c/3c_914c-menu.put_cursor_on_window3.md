

# $3c:914c menu.put_cursor_on_window3
> カーソルを3つ目のメニューウインドウ($7a00で管理)の現在選択されている項目に配置する。

### args:
+	in u8 $a4: cursor availablity flags on window-3.
	- 01: blink cursor.
+	in u8 $f0: frame counter. used to blink the cursor.
+	in u8 $7af0: offset of selected item (each menu item consists of 4-byte structure)
+	in MenuItem $7a00[]: cursor stop

### callers:
+	$3c:a7cd menu.render_cursor

### local variables:
none.

### notes:
unlike the sibling logics for other windows (controlled with $7800, $7900),
this logic processes 'blink' flag (bit 0 of $a4).
if that flag is set, the cursor is shown only if the frame counter value is of a multiple of 4.
in other words, blink cursor is shown in 1 frame per 4.
the following windows are operated as 'window-3':

-	(floor mode) items to cast onto npc/object
-	magics in magic menu
-	items in item menu
-	items in shop for selling
-	items in stomach
-	items in equipment menu
-	name entry at new game

### (pseudo)code:
```js
{
/*
; ----------------------------------------------------------------------------
    lda <$A4     ; 914C A5 A4
    bne .L_9151   ; 914E D0 01
.L_9150:
  	rts             ; 9150 60
; ----------------------------------------------------------------------------
.L_9151:
  	cmp #$01    ; 9151 C9 01
    beq .L_915B   ; 9153 F0 06
    lda <$F0     ; 9155 A5 F0
    and #$04    ; 9157 29 04
    bne .L_9150   ; 9159 D0 F5
.L_915B:
  	ldy $7AF0   ; 915B AC F0 7A
    ldx $7A00,y ; 915E BE 00 7A
    lda $7A01,y ; 9161 B9 01 7A
*/
$9164:
}
```

**fall through**


