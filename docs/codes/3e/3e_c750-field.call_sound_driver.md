
# $3e:c750 field.call_sound_driver
> サウンドドライバを呼び出して、音楽と効果音を再生する。

### code:
```js
{
	switch_2banks_thunk({per8kBank:a = 0x36}); //ff03
	return sound.update_playback();	//$36$8003();
}
```





