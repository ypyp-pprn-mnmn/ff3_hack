

# $3d:a9f9 menu.savefile.load_game_at
> 指定のアドレスにあるゲームの状態データ(0x400 bytes)をロードし現在のゲーム状態とする。

### args:

#### in:
+	u8 A : higher byte of the address to load (usually one of 0x64, 0x68, 0x6c)

#### out:
+	u8 $6000[0x400] : the game state

### callers:
+	yet to be investigated

### local variables:
+	ptr $80 : destination address game states to be loaded into (always $6000)
+	ptr $82 : source address game state to be loaded from

### notes:
save menu calls this function to render summary info on a particular file.

### (pseudo)code:
```js
{
	//write code here
$aa06:
}
```

**fall through**


