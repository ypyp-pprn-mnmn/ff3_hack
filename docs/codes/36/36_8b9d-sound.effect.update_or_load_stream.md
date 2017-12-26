
# $36:8b9d sound.effect.update_or_load_stream
> 新しいSE(効果音)が要求されている($7f49のmsbが1)場合、再生データを取得する。さもなければ、既存の再生データを更新する。

### args:
+	in,out u8 $7f49: sound effect id and load flags.
	- bit 7: play new. 0 on exit.
	- bit 6: play continue. 1 on exit.
	- bit 5-0: sound effect id. 0 on exit.

### local variables:
none.

### callers:
+	$36:8003 sound.update_playback

### notes:


### code:
```js
{
	a = $7f49;
	if (a == 0) {
$8bb7:
		return;
	}
	if (a == 0xff) {
$8bb1:
		$7f49++;
		return;
	}
	a <<= 1;
	if (carry) {
$8bad:
		sound.effect.load_stream();	//$8bb8();	//loadSoundEffectData?
	} else {
$8bad:
		sound.effect.update_each_track();	//$8c58();
	}
	return;
$8bb8:
/*
    lda $7F49   ; 8B9D AD 49 7F
    beq .L_8BB7   ; 8BA0 F0 15
		cmp #$FF    ; 8BA2 C9 FF
		beq .L_8BB1   ; 8BA4 F0 0B
			asl a       ; 8BA6 0A
			bcs .L_8BAD   ; 8BA7 B0 04
				jsr loadMusicData               ; 8BA9 20 58 8C
				rts             ; 8BAC 60
; ----------------------------------------------------------------------------
.L_8BAD:
			jsr .L_8BB8   ; 8BAD 20 B8 8B
			rts             ; 8BB0 60
; ----------------------------------------------------------------------------
.L_8BB1:
		inc $7F49   ; 8BB1 EE 49 7F
		jsr .L_8C29   ; 8BB4 20 29 8C
.L_8BB7:
  	rts             ; 8BB7 60
*/
}
```




