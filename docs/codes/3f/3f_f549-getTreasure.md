
# $3f:f549 getTreasure


### args:
+	[in] u8 $0710[0x10] : treasureIds
+	[in] u8 $45 : eventParam
+	[in] u8 $49 : warpparam.+01 & 0x20
+	[in] u8 $ba :
	-	00: chipId=d0-df,
	-	FF: chipId=e0-ef
	-	chipId:D0-DF = staticChipId:7C(宝箱)
+	[out] a : messageId

### code:
```js
{
	x = $45 & #0f;
	x = $8f = $0710.x;
	if ( ($ba != 0 ) //bne f55c
		|| ($49 == 0)) //bne f5b2
	{
$f55c:
		getTreasureParam();	//$f5c4();
		$80 = a;	//itemid
		$81 = #01;
		if ((a < #57)  //bcs f571
			&& (a >= #4f)) //bcc f571
		{	//矢なので20個入手
$f56d:
			$81 = #14;	//20
		}
$f571:
		switch_to_character_logics_bank();	//$f727();
		$bb = $80;
		floor.searchSpaceForItem();	//$3c$937e();
		if (!carry) { //bcs f5af
			$60c0.x = $80;
			a = $81 + $60e0.x;
			if (a > 99) {
				a = 99;
			}
$f58e:
			$60e0.x = a;
			invertTreasureGotFlag(); //$f640();
			if ($ba >= 0) { //bmi f5ac
				if ($8f < #e0) { //bcs f5a1
					a = #59;
					return;
				}
$f5a1:
				$ab = #20;	//20:occur encounter
				$6a = $8f;	//encounter id
				a = #02;	"たからばこの...とつぜんモンスターが..."
				return;
			}
$f5ac:
			a = #76;	//"こんなところにxxが！"
			return;
		}
$f5af:
		a = #50;	//"もちものがいっぱいです"
		return;
	}
$f5b2:
	getTreasureParam();	//$f5c4();
	$bb = x = a;	//index
	getTreasureGil();	//$f5d4();
	incrementGil();	//$f5ff();
	invertTreasureGotFlag();	//$f640();
	a = #01;
	return;
$f5c4:
}
```




