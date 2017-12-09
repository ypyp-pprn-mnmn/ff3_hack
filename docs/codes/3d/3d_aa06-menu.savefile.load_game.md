
# $3d:aa06 menu.savefile.load_game
> $82が示すバッファにあるゲームの状態データ(0x400 bytes)をロードし現在のゲーム状態とする。

### args:

#### in:
+	ptr $80: destination address game states to be loaded into (always $6000)
+	ptr $82: pointer to source buffer containing game states to be loaded from

#### out:
+	u8 $6000[0x400] : the game states

### callers:
+	$3d:aa18 menu.savefile.save_or_load_current_game_with_buffer

### local variables:
none

### notes:

### (pseudo)code:
```js
{
	//write code here
}
```

