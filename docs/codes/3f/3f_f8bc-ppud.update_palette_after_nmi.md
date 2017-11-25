

# $3f:f8bc ppud.update_palette_after_nmi
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
    ppud.await_nmi_completion();    //$fb80
    ppud.upload_palette();  //$f897
    return ppud.sync_registers_with_cache();    //$fbcb
}
```


