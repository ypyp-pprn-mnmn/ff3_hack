
# $3e:c758 field.call_sound_driver_and_restore_banks
> サウンドドライバを呼び出して、音楽と効果音を再生し、その後バンクを$57にもとづいてマップする。

### args:
+	in u8 $57: bank number to set on exit

### callers:
+	`1E:93EB:4C 58 C7  JMP field.call_update_playback_ex`
+	`1E:943B:4C 58 C7  JMP field.call_update_playback_ex`
+	`1E:BBA2:4C 58 C7  JMP field.call_update_playback_ex`
+	`1F:C009:4C 58 C7  JMP field.call_update_playback_ex`
+	`1E:9000:20 58 C7  JSR field.call_update_playback_ex`
+	`1E:90DE:20 58 C7  JSR field.call_update_playback_ex`
+	`1E:9B10:20 58 C7  JSR field.call_sound_driver_and_re`
+	`1E:A311:20 58 C7  JSR field.call_sound_driver_and_re`
+	`1E:A31E:20 58 C7  JSR field.call_sound_driver_and_re`
+	`1E:A7AC:20 58 C7  JSR field.call_sound_driver_and_re`
+	`1E:A7D7:20 58 C7  JSR field.call_sound_driver_and_re` @$3d:a7cd menu.render_cursor
+	`1E:AA63:20 58 C7  JSR field.call_sound_driver_and_re` right before 'rts' (might be replaced with JMP)
+	`1E:B1D4:20 58 C7  JSR field.call_sound_driver_and_re`
+	`1E:B1E1:20 58 C7  JSR field.call_sound_driver_and_re`
+	`1E:B902:20 58 C7  JSR field.call_sound_driver_and_re`
+	`1E:BA5F:20 58 C7  JSR field.call_sound_driver_and_re`

### local variables:
none.

### notes:
this function is similar to `$3e:c750 field.call_sound_driver`,
but also does a switch of program banks (whose number is stored in $57).

### (pseudo)code:
```js
{
/*
    lda #$36    				; C758 A9 36
    jsr call_switchFirst2Banks  ; C75A 20 03 FF
    jsr .L_8003   				; C75D 20 03 80
    lda <$57     				; C760 A5 57
    jmp call_switchFirst2Banks  ; C762 4C 03 FF
*/
}
```

