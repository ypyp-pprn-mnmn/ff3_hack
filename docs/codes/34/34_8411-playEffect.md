
# $34:8411 playEffect



### args:
+ [in] u8 $7e9a :	action side flag (80:actor enemy 40:target enemy)
+ [in] u8 $7ec2 : effectType; set by commandHandler, usually commandId
+ [in] u8 $7ec3 : (0 or 1?)

### (pseudo-)code:
```js
{
	a = $7e9a;
	rol a;rol a;rol a; a &= 1;
	$7e6f = a;	//bit6 of $7e9a
	y = $7ec2; a = $83f8.y;
	if (1 == a) a += $7ec3;
$842a:
	$7e97 = a;
	y = a << 1;
	$18,19 = $843e.y,$843f.y;
	(*$18)();	//jumptable
$843e:
//	func	addr	$7ec2
	00	8613	4,10	//たたかう うたう
	01	8577	13,14	//? アイテム/まほう
	02	85ed
	03	8576	0,1,a,b,c,d,e	//? ? ? しらべる みやぶる ぬすむ
	04	853b	2	//ぜんしん
	05	8540	3	//こうたい
	06	8528	5	//ぼうぎょ
	07	852d	8	//ジャンプ
	08	8516	9	//(着地)
	09	850a	f	//ためる
	0a	8505	11	//おどかす
	0b	84fb	12	//おうえん
	0c	84f6	15	//
	0d	84d7	6,7	//にげる とんずら
	0e	8470	16	//死亡エフェクト (dispCommand_0D)
	0f	8460	17	//ダメージ表示(dispCommand_0C)
	10	8555	18	//かえるアクション
$8460:
}
```



