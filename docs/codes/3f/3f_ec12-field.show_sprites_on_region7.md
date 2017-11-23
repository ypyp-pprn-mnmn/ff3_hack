
# $3f:ec12 field::show_sprites_on_region7 (bug?)


## callers:
+	`1F:C9C1:20 12 EC  JSR field.show_sprites_on_region7`
## notes:
called when choose item dialog (window_type=2) is about to close
## code:
```js
{
/*
 1F:EC12:A2 07     LDX #$07
 1F:EC14:A9 01     LDA #$01
 1F:EC16:D0 02     BNE $EC1A
*/
	return field.showhide_sprites_by_region(A = 1, X = 7);	//bne $ec1a
}
```



