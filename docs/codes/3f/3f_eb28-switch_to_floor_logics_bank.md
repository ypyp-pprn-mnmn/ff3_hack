
# $3f:eb28 switch_to_floor_logics_bank


### notes:
Bank $3c stores codes implementing logics around floor/menu.
This logic's implementation is identical to `$3f:f727 switch_to_character_logics_bank`.

### code:
```js
{
	/*
	switch_to_floor_logic_bank:
	; bank $3c
 	1F:EB28:A9 3C     LDA #$3C
 	1F:EB2A:4C 03 FF  JMP call_switch_2banks

	1F:F727:A9 3C     LDA #$3C
 	1F:F729:4C 03 FF  JMP call_switch_2banks
 	*/
	return call_switch_2pages(a = 0x3c);	//jmp $ff03
$eb2d:
}
```



