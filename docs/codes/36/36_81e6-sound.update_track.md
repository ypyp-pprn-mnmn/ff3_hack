
# $36:81e6 sound.update_track
> 指定されたトラックについて音楽または効果音の再生データを更新する。

### args:
+	in u8 $d0: track #, [0...7). music 5 channels + SE 2 channels.
+	in u8 $7f4a[7]: ?, indexed by $d0, some control flag. where:
	-   01: feed next wave data?
	-   80: channel available
+	in,out u8 $7f5f[7]: note length in 96th of a whole note.
	-	some counter, indexed by $d0, decremented by 1 on each call.
	-	if it reaches 0, next byte is fetched from the stream.
+	in,out u16 [$7f97[7],$7f9e[7]]: note counter?
	-	some counter, indexed by $d0, decremented by 1 per a note played ($7f5f had reached to 0)

### callers:
+	$36:8b2d sound.music.update_each_track
+	$36:8c58 sound.effect.update_each_track

### code
```js
{
	x = $d0;
	if ($7f4a.x < 0) {
		if ($7f5f.x == 0) {
			sound.fetch_note_for_track({track_no: x});	//$820b();
		}
	$81f5:
		x = $d0;
		$7f5f.x--;
		if ($7f97.x == 0) {
	$81ff:
			if ($7f9e.x != 0) {
				$7f9e.x--;
				$7f97.x--;
			}
		} else if ($7f97.x != 0) {
	$8207:
			$7f97.x--;
		}
	}
$820a:
	return;
/*
    ldx <$D0     ; 81E6 A6 D0
    lda $7F4A,x ; 81E8 BD 4A 7F
    bpl .L_820A   ; 81EB 10 1D
		lda $7F5F,x ; 81ED BD 5F 7F
		bne .L_81F5   ; 81F0 D0 03
			jsr .L_820B   ; 81F2 20 0B 82
	.L_81F5:
		ldx <$D0     ; 81F5 A6 D0
		dec $7F5F,x ; 81F7 DE 5F 7F
		lda $7F97,x ; 81FA BD 97 7F
		bne .L_8207   ; 81FD D0 08
			lda $7F9E,x ; 81FF BD 9E 7F
			beq .L_820A   ; 8202 F0 06
				dec $7F9E,x ; 8204 DE 9E 7F
	.L_8207:
		dec $7F97,x ; 8207 DE 97 7F
.L_820A:
    rts             ; 820A 60
*/
}
```


