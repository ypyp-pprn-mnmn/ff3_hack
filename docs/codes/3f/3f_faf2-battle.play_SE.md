
# $3f:faf2 battle.play_SE
> 効果音を鳴らす。

### args:
-	in u8 $c9: sound effect requested. 0: no, otherwise: yes.
-	in u8 $ca: sound effect id

### callers:
-	$3f:fb30 battle.irq_handler

### code:
```js
{
	push(a = x);
	push(a = y);
	if ((a = $c9) != 0) { //beq $fb05
		$7f49 = $ca | 0x80;
		$c9 = 0;
	}
	switch_16k_synchronized_nocache({bank:a = 0x1b});	//$3f:fb89;
	sound.update_playback();	//$36$8003;	//sound?
	switch_16k_synchronized_nocache({bank:a = $ab});		//$ab : last $fb87 param (=last bank no)
	y = pop();
	x = pop();
	return;
}
```




