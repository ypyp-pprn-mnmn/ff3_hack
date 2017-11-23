
# $33:b6f3 presentEffectAtTargetWorker

### code:
```js
{
	$c9++;		//doesPlaySound(1:play)
	$7e9c = 1;
	do {
$b6fa:
		presentEffectFrameAtTarget();	//$33:b711();
		$7e9c++;
	} while (($7e9c - 1) != $7300);
$b70b:
	fill_A0hBytes_f0_at$0200andSet$c8_0();	//$33:a05e();
	return call_waitNmi();	//$3f:f8b0();
}
```


