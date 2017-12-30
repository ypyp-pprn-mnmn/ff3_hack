
# $3d:aed5 menu.shop.update_eligiblity_for_item
> short description of the function

### args:
+	yet to be investigated

### callers:
+	yet to be investigated

### local variables:
+	yet to be investigated

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    jsr menu.clear_eligible_status_of_all_characters; AED5 20 C3 AE
    lda $79F0   ; AED8 AD F0 79
    lsr a       ; AEDB 4A
    lsr a       ; AEDC 4A
    sta <$8E     ; AEDD 85 8E
    tax             ; AEDF AA
	lda $7B80,x ; AEE0 BD 80 7B
*/
}
```
**fall through**


