
# $36:899f switch2ndBankToSoundDataBank


### args:
+	[in] u8 $7f43 : soundId
```js
{
	$8000 = #7;	//switch 2nd bank
	x = 0;
	if ($7f43 >= #19) { //bcc 89b8
		x++;
		if ($7f43 >= #2b) { //bcc 89b8
			x++;
			if ($7f43 >= #3b) { //bcc 89b8
				x++;
			}
		}
	}
$89b8:
	$8001 = $89bf,x
	return;
}
```



