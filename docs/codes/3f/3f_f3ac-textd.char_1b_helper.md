
# $3f:f3ac textd.char_1b_helper
> 

### args:
+	in u8 $84: parameter byte of char code 0x1b
+	in,out u8 $1e: ?
+	in,out u8 $1f: lines drawn?
+	out u8 $90: text index
+	in u8 $97: ?
+	in u8 $98: ?

### callers:
+	yet to be investigated

### local variables:
+	yet to be investigated

### notes:


### (pseudo)code:
```js
{
/*
	lda     $84                             ; F3AC A5 84
	lsr     a                               ; F3AE 4A
	lda     #$01                            ; F3AF A9 01
	bcc     LF3B5                           ; F3B1 90 02
	lda     #$0F                            ; F3B3 A9 0F
LF3B5:
	sta     $90                             ; F3B5 85 90
	ldx     $7AF1                           ; F3B7 AE F1 7A
	lda     $1E                             ; F3BA A5 1E
	bne     LF3C2                           ; F3BC D0 04
	inc     $1E                             ; F3BE E6 1E
	ldx     #$00                            ; F3C0 A2 00
LF3C2:
	txa                                     ; F3C2 8A
	clc                                     ; F3C3 18
	adc     #$04                            ; F3C4 69 04
	sta     $7AF1                           ; F3C6 8D F1 7A
	lda     $90                             ; F3C9 A5 90
	clc                                     ; F3CB 18
	adc     $97                             ; F3CC 65 97
	sta     $7A00,x                         ; F3CE 9D 00 7A
	lda     $98                             ; F3D1 A5 98
	clc                                     ; F3D3 18
	adc     $1F                             ; F3D4 65 1F
	sta     $7A01,x                         ; F3D6 9D 01 7A
	lda     #$1B                            ; F3D9 A9 1B
	sta     $7A02,x                         ; F3DB 9D 02 7A
	lda     $84                             ; F3DE A5 84
	sta     $7A03,x                         ; F3E0 9D 03 7A
	rts                                     ; F3E3 60
*/
}
```

