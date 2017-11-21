
# $34:9b79 playSoundEffect	//[set$ca_and_increment_$c9]

<summary></summary>

## (pseudo-)code:
```js
{
	a = #18; goto $9b83;	//papa	(move sound)
$9b7d:	a = 5; goto $9b83;	//pi	(decide sound)
$9b81:	a = 6;			//bee-bee	(invalid sound)
$9b83:	$ca = a;
	$c9++;
	return;
$9b88:
}
```



