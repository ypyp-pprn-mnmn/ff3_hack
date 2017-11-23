
# $3f:ea26 floor::getEvent?


### code:
```js
{
	$24 = 0;
	waitNmiBySetHandler();	//$ff00();
	field::callSoundDriver(); //$c750();
	a = $33;
	floor::getEventSourceCoodinates(); //$e4e9();
	if (carry) { //bcc ea3d
		//?? collided with object
		return floor::getObjectEvent(); //$e9bb();
	}
$ea3d:
	floor::processChipEvent(); //$e917();
	if (carry) { //bcc ea51
		$76 = a; //stringId
		$94,95 = #8200; //string ptr table base
		$44 = $43;
	}
$ea51:
	$44 = $43;
	return;
$ea56:
}
```



