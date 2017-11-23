
# $3f:f727 switch_to_character_logics_bank


### notes:
This logic's implementation is identical to `$3f:eb28 switch_to_floor_logics_bank`.
It might not be a bug, as how the banks are arranged to place the logic is completely physical matter,
hence it is irrevant to programmers' original intention. 

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
	call_switch_2banks({per8kBase:a = 0x3c}); //ff03
}
```



