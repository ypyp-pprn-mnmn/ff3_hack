
# $3e:c06e menu.opening.title_page
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
        lda     #$36                            ; C06E A9 36
        jsr     call_switchFirst2Banks          ; C070 20 03 FF
        lda     #$00                            ; C073 A9 00
        sta     $7F49                           ; C075 8D 49 7F
        jsr     invokeEffectFunction            ; C078 20 00 80
        lda     #$00                            ; C07B A9 00
        sta     $2001                           ; C07D 8D 01 20
        sta     $FE                             ; C080 85 FE
        lda     #$88                            ; C082 A9 88
        sta     $FF                             ; C084 85 FF
        sta     $FD                             ; C086 85 FD
        sta     $2000                           ; C088 8D 00 20
        ldx     #$FF                            ; C08B A2 FF
        txs                                     ; C08D 9A
        lda     #$00                            ; C08E A9 00
        jsr     LC49E                           ; C090 20 9E C4
        jsr     LC486                           ; C093 20 86 C4
        jsr     waitNmiBySetHandler             ; C096 20 00 FF
        lda     #$02                            ; C099 A9 02
        sta     $4014                           ; C09B 8D 14 40
        jsr     LD308                           ; C09E 20 08 D3
        lda     $FA                             ; C0A1 A5 FA
        cmp     #$77                            ; C0A3 C9 77
        beq     LC0C3                           ; C0A5 F0 1C
        lda     #$3A                            ; C0A7 A9 3A
        jsr     call_switch1stBank              ; C0A9 20 06 FF
        jsr     L851B                           ; C0AC 20 1B 85
        lda     #$00                            ; C0AF A9 00
        sta     $2001                           ; C0B1 8D 01 20
        lda     #$77                            ; C0B4 A9 77
        sta     $FA                             ; C0B6 85 FA
        jsr     LDD06                           ; C0B8 20 06 DD
        lda     #$3A                            ; C0BB A9 3A
        jsr     call_switch1stBank              ; C0BD 20 06 FF
        jsr     effect07                        ; C0C0 20 2D 85
LC0C3:  jsr     switchToBank3C                  ; C0C3 20 8A C9
	;; will render title ticker
        jsr     LB9F6                           ; C0C6 20 F6 B9

        php                                     ; C0C9 08
        jsr     LC49E                           ; C0CA 20 9E C4
        lda     $6009                           ; C0CD AD 09 60
        sta     $27                             ; C0D0 85 27
        lda     $600A                           ; C0D2 AD 0A 60
        sta     $28                             ; C0D5 85 28
        lda     $600F                           ; C0D7 AD 0F 60
        sta     $46                             ; C0DA 85 46
        sta     $42                             ; C0DC 85 42
        lda     $6008                           ; C0DE AD 08 60
        sta     $78                             ; C0E1 85 78
        plp                                     ; C0E3 28
        bcs     LC0ED                           ; C0E4 B0 07
        lda     #$00                            ; C0E6 A9 00
        sta     $48                             ; C0E8 85 48
        jsr     dungeon.mainLoop                ; C0EA 20 DC E1
*/
}
```

