
# $3f:fddc copyTo7400


## args:
+	[in] u16 $46 : sourceBasePtr
+	[in] u8 $4a : bankToRestore
+	[in] u8 $4b : dataSize
+	[in] u8 A : sourceBank (per16k)
+	[out sizeis($4b) ] $7400 : destination
## code:
```js
{
	switch_16k_synchronized();	//jsr $3f:fb87()
	for (x = 0,y = 0;x < $4b;x++,y++) {
		$7400,x = $46[y];	//$46 = $bb1a + job*5
	}
	return switch_16k_synchronized({bank: a = $4a}); //jmp $3f:fb87
}
```



