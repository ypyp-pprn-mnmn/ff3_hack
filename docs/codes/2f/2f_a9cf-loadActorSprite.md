
# $2f:a9cf loadActorSprite?

### args:
+	[in] u8 x : actorIndex? 
+	[in] u8 $7d8b : ?

### code:
```js
{
	push (a = x);
	if ($7d8b.x != #ff) {	//beq a9ea
		$7e = a;
		$ab3d();
		$7e,7f = $1c,1d

		loadSprites(loadUsing:a = #5, base:$7e );	//;$a1b9();
	}
	x = pop a
	return;
}
```


