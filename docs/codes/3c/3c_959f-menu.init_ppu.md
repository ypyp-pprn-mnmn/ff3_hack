
# $3c:959f menu.init_ppu
> PPUの各レジスタを初期化する。

### args:
none.

### callers:
+	`1E:9B0D:20 9F 95  JSR menu.init_ppu`
+	`1E:A55B:20 9F 95  JSR menu.init_ppu`
+	`1E:A690:20 9F 95  JSR menu.init_ppu`
+	`1E:A8D6:20 9F 95  JSR menu.init_ppu`
+	`1E:9589:4C 9F 95  JMP menu.init_ppu`

### local variables:
none.

### notes:
write notes here

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

