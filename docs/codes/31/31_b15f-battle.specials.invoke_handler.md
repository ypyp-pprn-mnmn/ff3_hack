

# $31:b15f battle.specials.invoke_handler
> アクション(魔法・特殊攻撃)の計算を行うハンドラをそのパラメータの5byte目に基づいて呼び出す。

### args:
+	in u8 $7404 : handlerType (is actionParam[4]), see notes for details.

#### not directly used in this function, but available:
+	u8 $30: hit count
+	u8 $38: attack count
+	BattleCharacter* $6e: ptr to actor
+	BattleCharacter* $70: ptr to target
+	u8 $7c: hit count (with attr boost bonus)

### local variables:
+	ptr $18: jump table address
+	ptr $1a: pointer to handler

### static references:
+	ptr $ba9c[0x33?]: jump table, pointers of handlers

### callers:
+	$31:af77 battle.specials.execute

### notes:
for action names, see 3d260.
for action parameters, see 618c0.
handlers are defined as follows:

|ty| addr| processes
|--|-----|---------------------------------------
|00| B17C| HPダメージ
|01| B233| HP回復
|02| B276| トルネド
|03| B2B5| ドレイン
|04| B30C| ステータス付与
|05| B37A| 蘇生
|06| B3CA| ステータス回復
|07| B3F1| トード・ミニマム
|08| B474| プロテス
|09| B480| ヘイスト
|0a| B48C| リフレク
|0b| B49B| イレース
|0c| B4C8| サイトロ
|0d| B4B9| ライブラ
|0e| B4C9| ぞうしょく
|0f| B4D4| ぶんれつ_1
|10| B4F4| しょうかんまほう
|11| B4D4| ぶんれつ_2 (通常目にするのはこちら)
|12| B51F| じばく
|13| B56C| バリアチェンジ
|14| B5AA| エリクサー
|15| B5E7| ぼうぎょ
|16| B62C| かみつき
|17| B654| はどうほう
|18| B233| かいふく_1
|19| B658|
|1a| B657|
|1b| B679|
|1c| B67F|
|1d| B679|
|1e| B679|
|1f| B67F|
|20| B679|
|21| B679|
|22| B67C|
|23| B679|
|24| B679|
|25| B679|
|26| B679|
|27| B679|
|28| B685|
|29| B679|
|2a| B688|
|2b| B67F|
|2c| B679|
|2d| B679|
|2e| B682|
|2f| B6B0|
|30| B679|
|31| B679|
|32| B67F|
|33| B679| かまいたち

### (pseudo-)code:
```js
{

	$18,19 = ($7404 << 1) + 0xba9c;
	$1a,1b = *($18,$19)
	(*$1a)();	//funcptr
$b17c:
}
```




