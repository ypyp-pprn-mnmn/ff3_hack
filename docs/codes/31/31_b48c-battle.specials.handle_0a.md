
# $31:b48c battle.specials.handle_0a
> リフレク

### args:
+	in, out BattleCharacter* $70: target

### callers:
+	$31:b15f battle.specials.invoke_handler

### local variables:
none.

### notes:


### (pseudo)code:
```js
{
/*
	jsr clearEffectTargetIfMiss     ; B48C 20 21 B9
	beq .miss       	; B48F F0 09
		;; 'reflect' flag??
		ldy #$26        ; B491 A0 26
		lda [$70],y     ; B493 B1 70
		clc         	; B495 18
		adc #$01        ; B496 69 01
		sta [$70],y     ; B498 91 70
.miss:
	rts         		; B49A 60
*/
}
```

