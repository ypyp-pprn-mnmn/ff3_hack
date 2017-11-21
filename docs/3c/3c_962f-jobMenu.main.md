
# $3c:962f jobMenu::main


## args:
+	[in] u8 $7f,x : character offset
## (pseudo)code:
```js
{
	$96ba();
	$9592();
	$a685();
	$956f();
	jobMenu::getCosts();	//$ad85();
$963e:
	$a3 = $78f0 = 0;
	
	field::drawWindowOf(x = #0c );	//aaf1
	field::loadAndDrawString(a = #48 );	//$a87a

	field::drawWindowOf(x = #0d );
	$a878(a = #49 );

	field::drawWindowOf(x = #0e );
$965e:
	do {
		do {
			$aaa6(x = #0e);
			field::loadAndDrawString(a = #4a );	//$a87a
$9668:
			do {
				$a2 = 1;
				$a7cd();

				fieldMenu_updateCursorPos(incr:a = 8);	//$91a3();
				$9698();
				if ($25 != 0) return $961c(); //bne 961c
$967b:
			} while ($24 == 0); //beq 9668
$967f:
			$8f74();
			$96a5();
		} while (!carry); //bcc 965e
$9687:
		a = #70;
		$96da();
	} while (($20 & #80) == 0); //beq 965e
$9692:
	$ab8f();
	return $961c();	//jmp
}
```



