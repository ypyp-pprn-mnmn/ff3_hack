
# $36:831d sound.sum_lengths_2_3rd
> short description of the function

### args:
+	in u8 $d0: track #
+	in u8 $d1: channel id
+	in AuditoStream* $d3: pointer to stream
+	in u8 $d5: command byte fetched from stream

### callers:
+	$36:820b sound.fetch_note_for_track

### local variables:
+	yet to be investigated

### static references:
+	u8 $8815[0x10]: tone length, 2/3 of $8805.
	`48 36 24 1B 18 12 0D 0C 09 07 06 04 03 02 01 00`

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    lda <$D5     ; 831D A5 D5
    and #$0F    ; 831F 29 0F
    tax             ; 8321 AA
    lda $8815,x ; 8322 BD 15 88
    sta <$D8     ; 8325 85 D8
    ldy #$00    ; 8327 A0 00
    sty <$D9     ; 8329 84 D9
.L_832B:
        lda [$D3],y ; 832B B1 D3
        iny             ; 832D C8
        cmp #$D0    ; 832E C9 D0
        bcc .L_8346   ; 8330 90 14
        cmp #$E0    ; 8332 C9 E0
        bcs .L_8346   ; 8334 B0 10
        and #$0F    ; 8336 29 0F
        tax             ; 8338 AA
        lda $8815,x ; 8339 BD 15 88
        adc <$D8     ; 833C 65 D8
        sta <$D8     ; 833E 85 D8
        bcc .L_832B   ; 8340 90 E9
        inc <$D9     ; 8342 E6 D9
        bcs .L_832B   ; 8344 B0 E5
.L_8346:
    ldx <$D0     ; 8346 A6 D0
    lda <$D8     ; 8348 A5 D8
    sta $7F97,x ; 834A 9D 97 7F
    lda <$D9     ; 834D A5 D9
    sta $7F9E,x ; 834F 9D 9E 7F
    rts             ; 8352 60
*/
}
```

