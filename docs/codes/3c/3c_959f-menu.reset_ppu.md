
# $3c:959f menu.reset_ppu
> PPUの各レジスタを初期化する。Ctrlレジスタ($2000)は事前に設定した内容($ff)に従う。

### args:
+ in u8 $ff: ppu ctrl cache.

### callers:
+	`1E:9B0D:20 9F 95  JSR menu.init_ppu`
+	`1E:A55B:20 9F 95  JSR menu.init_ppu`
+	`1E:A690:20 9F 95  JSR menu.init_ppu`
+	`1E:A8D6:20 9F 95  JSR menu.init_ppu`
+	`1E:9589:4C 9F 95  JMP menu.init_ppu`

### local variables:
none.

### notes:
this function is very similar to `$3d:b369 menu.init_ppu`.
unlike other one, this function doesn't set cache values (at $ff).

### (pseudo)code:
```js
{
/*
menu__init_ppu:          
  lda $FF                  
  sta PpuControl_2000      
  lda #$1E                 
  sta PpuMask_2001         
  lda #$00                 
  sta PpuScroll_2005       
  sta PpuScroll_2005       
  rts                      
*/
$95b2:
}
```

