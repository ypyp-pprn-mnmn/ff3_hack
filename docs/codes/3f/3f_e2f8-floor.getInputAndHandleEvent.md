
# $3f:e2f8 floor::getInputAndHandleEvent


### code:
```js
{
	if ($50 != 0) { //beq e32e
		a = #02;
		$d469();
		if ($50 < 0) { //bpl e31f
$e305:
			if ($50 == #80) {//bne e314
$e309:
				call_switchFirst2Banks(per8kbank:a = #1e); //ff03
				$1f:bff7();
				//goto $e325
			} else {
$e314:
				call_switchFirst2Banks(per8kbank:a = #1e); //ff03
				$1f:bffa();
				//goto $e325
			}
		} else {
$e31f:
			switch1stBankTo3C();	//$eb28();
			$3c:af1f();
		}
$e325:
		$50 = 0;
		return $e7f8(a = 1);
	}
$e32e:
	if ($6c == 0) { //bne e36e
		if ( $24 != 0 ) { //beq e339
			return floor::getEvent(); //ea26 this will set $6c
		}
$e339:
	//...
	}
$e36e:	//($6c != 0)
	if ($4b != #ff) { //bne e37d
		return;
	}
$e374:
	floor::getInputOrFireObjectEvent(); //$d219();	//getAndMaskInput
	if ( ($20 & #0f) == 0) { //bne e37e
$e37d:
		return; 
	}
$e37e:	//十字キーのどれかが押されてる
	$33 = a;
	floor::fireOnMove();	//$e396();
	if (carry) return;	//bcs e37d
$e385:
	switch1stBankTo3C();	//$eb28();
	$3c:b6da();
	$6021 &= #bf;
	return $ca67();
}
```




