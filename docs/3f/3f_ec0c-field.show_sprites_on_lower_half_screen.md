
# $3f:ec0c field::show_sprites_on_lower_half_screen


## callers:
+	`1F:C9B6:20 0C EC  JSR field.show_sprites_on_region6`
## code:
```js
{
/*
 1F:EC0C:A2 06     LDX #$06
 1F:EC0E:A9 01     LDA #$01
 1F:EC10:D0 08     BNE $EC1A
*/
	return field.showhide_sprites_by_region(A = 1, X = 6);	//bne $ec1a
}
```



