
# $36:899f sound.map_audio_stream_into_2nd_page
> 指定のmusic_idが表す音楽データを2page目にマップする。(A000-BFFFをswitchする)

### args:
+	[in] u8 $7f43 : music_id

### static references:
+	u8 $89bf[4]: bank number of which the stream data of music (specified by music_id) located in. where:
	+ 0x37: for music_id [0x00...0x19)
	+ 0x38: for music_id [0x19...0x2b)
	+ 0x39: for music_id [0x2b...0x3b)
	+ 0x09: for music_id [0x3b...TBC)

### notes:
former name: switch2ndBankToSoundDataBank

### code:
```js
{
	$8000 = 0x7;	//switch 2nd bank
	x = 0;
	if ($7f43 >= 0x19) { //bcc 89b8
		x++;
		if ($7f43 >= 0x2b) { //bcc 89b8
			x++;
			if ($7f43 >= 0x3b) { //bcc 89b8
				x++;
			}
		}
	}
$89b8:
	$8001 = $89bf.x
	return;
$89bf:
	[0x37, 0x38, 0x39, 0x09];
}
```




