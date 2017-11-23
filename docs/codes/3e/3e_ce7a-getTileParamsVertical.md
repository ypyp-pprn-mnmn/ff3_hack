
# $3e:ce7a getTileParamsVertical


## args:
+	[in] ptr $80 : pMapData (7000-7eff)
## code:
```js
{
	for (x;x < #10;x++) {
		y = $80[y = 0];
		$0780.x = $0500.y;
		$0790.x = $0580.y;
		$07a0.x = $0600.y;
		$07b0.x = $0680.y;
		$07c0.x = $0700.y;
		$81 = #70 | ((($81 + 1) & #0f) % #0f); //cmp #$0f, bcc, sbc #$0f
	}
}
```




