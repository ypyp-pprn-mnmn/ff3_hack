
# $31:a4f6 loadMobParam

<summary></summary>

## args:
+ [in] u8 A : groupNo?
+ [in] u8 Y : enemyNo
+ [in] u8 $7d6b.x : enemyIds
## (pseudo-)code:
```js
{
	u16 base (=$30:8000)
 	mobid = $26 where $7d6b,x where x = initial A
	u16 $24 dataPtr = base + mobid * 10h
	u16 $5d destPtr = $7675 + $27 * 40h where $27 = initital Y

	dest[0x2c] = $27 | 0x80 & 0xe7
	dest[0] = data[0]	//lv
	$18 = data[1]		//hp.low
	$19 = data[2]		//hp.high
	dest[3,5] = $18
	dest[4,6] = $19	
	dest[0x37] = data[3]
	dest[0xf] = data[4]
	//jsr a614 {
		[in] u16 $24 srcPtr
		[in] u16 $5d destPtr
		[in] u8 $49 destOffset
		[in,out] u8 $4a srcOffset
		dest[$49++] = data[$4a++]
		$1c = $9000 + 3*data[$4a++]
		$18,19,1a = $1c[0,1,2]
		dest[$49++] = $18
		dest[$49++] = $19
		dest[$49++] = $1a
		dest[$49] = data[$4a++]
	}
	$4a = 0x05;
	$49 = 0x12; a614();	//mdef
	$49 = 0x16; a614();	//atk
	$49 = 0x20; a614();	//def
	dest[0x29] = dest[0x19] >> 1
	dest[0x28] = 5
	$18 = (data[7] & 0x0f)*(2+4)
	dest[0x10] = $18
	$18 = ((data[7]&0xf0)>>3)*3	//A = data[7] & 0xf0	//fd47 : A >>= 2
	dest[0x11] = $18
	
	$1c = $9200 + data[0xE] * 8	//bank:30
	for (x = 0;x < 8;x++) 
		dest[0x38+x] = $26+x = $1c[x]
	dest[0x36] = data[0xF]
	dest[0x35] = $26
	dest[0x1] = 0
}
```



