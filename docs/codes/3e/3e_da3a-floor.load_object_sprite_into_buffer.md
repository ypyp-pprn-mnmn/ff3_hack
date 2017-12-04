

# $3e:da3a floor.load_object_sprite_into_buffer


### args:
+	[out] nes_sprite_attr $0200[4]: sprite attribute buffer, indexed with the offset ($26), to be updated with 4 entries of attributes which as a whole forming mob character's sprite (or "npc") 
+	[in,out] u8 $26 : sprite offset
+	[in] ptr $80 : building info (= $700e.x,$700f.x + 0|8 + $7105.x)
	-	$700e.x :
		-	objparam.+03 & 3 == 0 : #b43a
		-	objparam.+03 & 3 == 1 : #b44a
		-	objparam.+03 & 3 == 2 : #b42a
		-	objparam.+03 & 3 == 3 : #b41a
	-	$7105.x :
		-	(objparam.+03 << 4) & #c0
+	[in] u8 $82 : tile index offset

### code:
```js
{
	y = 0;
	x = $26;
	$0200.x = $0204.x = a = $41; //sprite.x
	$0208.x = $020c.x = a + 8;
	$0203.x = $020b.x = a = $40; //sprite.y
	$0207.x = $020f.x = a + 8;
	$0201.x = $80[y] + $82;	//sprite.tileIndex
	$0202.x = $80[++y];	//sprite.attribute
	$0209.x = $80[++y] + $82;
	$020a.x = $80[++y];
	$0205.x = $80[++y] + $82;
	$0206.x = $80[++y];
	$020d.x = $80[++y] + $82;
	$020e.x = $80[++y];
	$26 += 0x10;
	return;
$daa3:
}
```





