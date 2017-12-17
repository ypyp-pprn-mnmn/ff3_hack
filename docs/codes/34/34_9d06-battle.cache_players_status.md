
# $34:9d06 battle.cache_players_status
> プレイヤーキャラ4人分のステータスをキャッシュする

### args:
+	yet to be investigated

### callers:
+	$35:ba41 battle.process_poison

### local variables:
+	u8 $52: player_index

### notes:


### (pseudo)code:
```js
{
/*
        lda     #$00                            ; 9D06 A9 00
        sta     $52                             ; 9D08 85 52
L9D0A:  jsr     updatePlayerOffset              ; 9D0A 20 41 A5
        jsr     cachePlayerStatus               ; 9D0D 20 1D 9D
        inc     $52                             ; 9D10 E6 52
        lda     $52                             ; 9D12 A5 52
        cmp     #$04                            ; 9D14 C9 04
        bne     L9D0A                           ; 9D16 D0 F2
        lda     #$00                            ; 9D18 A9 00
        sta     $52                             ; 9D1A 85 52
        rts                                     ; 9D1C 60
*/
}
```

