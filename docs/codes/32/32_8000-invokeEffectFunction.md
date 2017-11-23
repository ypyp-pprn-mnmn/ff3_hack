
# $32:8000 invokeEffectFunction

### args:
+	[in] u8 A : effectId (00-19h)
	- 01:$9a1c selectTarget
	- 03:$9f11 presentCharacter? ($34:8185)+
	- 04:$a0c0 味方打撃
	- 0d:$bafd 魔法
	- 14:$be9a 移動

### code:
```js
{
	y = a << 1;
	$96,97 = $800f.y,$8010.y;
	return (*$0096)();
}
```

