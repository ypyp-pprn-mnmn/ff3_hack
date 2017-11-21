
# $3f:f970 copyToVram


## args:
+	[in] u16 $7e : sourceBuffer
+	[in] u16 $80 : destVramAddr
+	[in] u8 $82 : length (in per 8x8pixel. = per 0x10bytes)
+	[in] u8 $84 : sourceBank(per16k)
+	[in] u8 $92 : use_palette (1: yes, 0: no)
+	[in] u8 $7300[] : palette (used if $92 != 0)
+	[in] u8 $7cf3 : init_completed (1: yes, 0: no( still-initializing ))
## code:
```js
{
	$83 = $82 & 3;
	$82 >>= 2;
	for ($82;$82 != 0;$82--) {
$f97a:		switch_16k_synchronized(a = $84);//fb87
		a = $7cf3;
		if (0 != 0) waitNmi();	//fb80
$f987:	
		setVramAddr(high:a = $81,low:x = $80); //$f8e0
		// 1回の ループで 4 tiles 分コピーする。 (1 tile = 8x8 pixel)
		for (y = 0;y != #40;y++) {
$f990:
			a = $7e[y];
			x = $92;
			if (x != 0) {
				x = a; a = $7300.x;
			}
$f99a:			$2007 = a;	//vram io
		}
$f9a2:
		a = $7cf3;
		if (0 != a) updatePpuScrollNoWait();	//$3f:f8cb();
$f9aa:
		a = 0;
		$2005 = a; $2005 = a;	//bg.scroll.x, bg.scroll.y
		offset$7e_16(a = #40); //$3f:f8f2()
		offset$80_16(a = #40); //$3f:f8fe()
	}
$f9c0:
	a = $83;
	// 余りのタイルをコピーする
	if (a != 0) {  // beq $f9fe;
$f9c4:
    	mul8x8_reg(a,x = #10);	//$f8ea
    	$82 = a;
    	a = $7cf3;
    	if (a != 0) waitNmi();	//$fb80
$f9d3:
    	setVramAddr(high:a = $81,low:x = $80);	//f8e0
    	y = 0;
    	do {
$f9dc:
    		a = $7e[y]; x = $92;
    		if (x != 0) {
    			x = a; a = $7300.x;
    		}
$f9e6:
            $2007 = a;	//vram io
    	} while ( ++y != $82 );
$f9ee:
        a = $7cf3;
    	if ( a != 0) updatePpuScrollNoWait();	//$3f:f8cb()
$f9f6:
        a = 0;
    	$2005 = a; $2005 = a;	//bg.scroll.x ;bg.scroll.y
	}
$f9fe:	
	return switchFirst2Banks(a = $7cf6);//jmp $f891
}
```



