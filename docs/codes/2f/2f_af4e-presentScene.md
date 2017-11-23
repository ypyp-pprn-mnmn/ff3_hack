
# $2f:af4e presentScene	

>invoke$af74

### args:
+	[in] u8 A : commandId (00-25h)
	-	01 : さがる(char:$52)
	-	02 : 指示するキャラが前に出る(char:$52)
	-	03 : playEffect_05 (back(03) )
	-	04 : playEffect_04 (forward(02) )
	-	07 : playEffect_0e(死亡・味方)
	-	08 : $b38b 行動終了したキャラを元の位置まで戻す
	-	09 : $b38e 行動中のキャラを示す(一定のラインまで前に出る)
	-	0a : playEffect_0e(死亡・敵 $7e=死亡bit(各bitが敵1体に相当) )
	-	0b : playEffect_0e
		-	(蘇生? bitが立っている敵の枠に敵がいたならグラ復活
		-	 生存かつ非表示の敵がいたとき $7e=生存bit で呼ばれる)
	-	0C : 敵生成(召還・分裂・増殖) playEffect_0F (disp_0C)
	-	0d : playEffect_0c (escape(06/07) : $7e9a(sideflag) < 0)
	-	0e :
	-	0F : prize($35:bb49)
	-	10 : 対象選択
	-	12 : 打撃モーション&エフェクト(char:$52)
	-	13 : presentCharacter($34:8185)
	-	14 : playEffect_00 (fight/sing 被弾モーション?)
	-	15 : playEffect_06 (defend(05) )
	-	16 : playEffect_09 (charge(0f) 通常)
	-	17 : playEffect_09 (charge(0f) ためすぎ)
	-	18 : playEffect_07 (jump(08) )
	-	19 : playEffect_08 (landing(09) )
	-	1a : playEffect_0a (intimidate(11) )
	-	1b : playEffect_0b (cheer(12) )
	-	1c : playEffect_0F (disp_0C) ダメージ表示?
	-	1d : playEffect_01 (command13/ cast/item)
	-	1f : playEffect_00 行動する敵が点滅
	-	20 : playEffect_00 (fight/sing 敵の打撃エフェクト?)
	-	21 : playEffect_0d (escape(06/07) : $7e9a(effectside) >= 0)
	-	22 : playEffect_01 (magicparam+06 == #07)
	-	23 : playEffect_01 (magicparam+06 == #0d)
	-	24 : playEffect_0c (command15)
+	[in] u8 X : actorIndex
+	[out] u8 $7d7d : 0

### local variables:
+	u16 $2f:af74 : functionTable

### notes:
各種ゲームシーン表示系のルーチンから呼ばれる

### code:
```js
{
	$93 = a;
	push (a = x);
	push (a = y);
	$95 = x;
	y = a = $93 << 1;
	$93,94 = $af74.y,$af75.y

	callPtrOn$0093();
$af69:
	$7d7d = 0;
	y = a = pop;
	x = a = pop;
}
```

