
# $3f:fd8b battle.eligibility_flags_from_user_type
> 各アイテムに設定された利用可能者タイプから、各ジョブの利用資格フラグを取得する。

### args:
+	in u8 X: userTypeId (itemParam[7])
+	out u8 $3b[3]: eligibility flags for job.

### code:
```js
{
	switch_16k_synchronized({bank16k:a = 0x00});
	[$3b,$3c,$3d] = [$00$8900.x, $00$8901.x, $00$8902.x];
	return switch_16k_synchronized({bank16k:a = 0x1a});
/*
    lda #$00    ; FD8B A9 00
    jsr switch_16k_synchronized     ; FD8D 20 87 FB
    lda $8900,x ; FD90 BD 00 89
    sta <$3B     ; FD93 85 3B
    inx             ; FD95 E8
    lda $8900,x ; FD96 BD 00 89
    sta <$3C     ; FD99 85 3C
    inx             ; FD9B E8
    lda $8900,x ; FD9C BD 00 89
    sta <$3D     ; FD9F 85 3D
    lda #$1A    ; FDA1 A9 1A
	jmp switch_16k_synchronized     ; FDA3 4C 87 FB
*/
}
```


