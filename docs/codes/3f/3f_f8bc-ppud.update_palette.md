
# $3f:f8bc ppud.update_palette
> awaits nmi, then barely updates palette.

### args:
+	see [$3f:f897 ppud.up*load*_palette]

### callers:
+	yet to be investigated

### local variables:
+	none

### notes:


### (pseudo)code:
```js
{
/*
 1F:F8BC:20 80 FB  JSR await_nmi_completion
 1F:F8BF:20 97 F8  JSR ppud.upload_palette
 1F:F8C2:4C CB F8  JMP ppud.reset_registers
*/
}
```

