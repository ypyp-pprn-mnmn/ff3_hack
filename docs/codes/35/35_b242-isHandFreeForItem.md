
# $35:b242 isHandFreeForItem



### args:
+ [in] itemid $3e : toRemove
+ [in] itemid $40 : toEquip
+ [in] itemid $7af5 : righthand
+ [in] itemid $7af9 : lefthand
+ [out] bool carry : 0:ok 1:bad combination

### notes:
>外そうとしている手の逆に着けてるものと着けようとしている物の組み合わせを調べる

		素手	片手	竪琴	弓	矢	盾	防具その他
	(id)	00	01	46	4a	4f	58	(62-)
			00	45	49	4e	57	61
	00-00	o	o	o	o	o	o
	01-45	 	o	x	x	x	o
	46-49 			x	x	x	x
	4a-4e 				x	o	x
	4f-57 					x	x
	58-64						o

### (pseudo-)code:
```js
{
	$1d = $40;	//着けようとしてるもの
	if ((a = $7af5) == $3e) {	//bne $b250
		$1c = $7af9;	//右手と一致したので左手を見る
	}
	if ((a = $1d) >= $1c) { //bcc $b260
		push (a = $1c); $1d = a; $1c = pop a;
	}
	//here always $1c > $1d
$b260:
	if ((a = $1c) == 0)	$b2a5;		//ok:(empty)
	if (a >= #62) $b2a6;			//fail:かわのぼうし
	if (a >= #58) {				//かわのたて
		if ((a = $1d) == 0) $b2a5;	//
		if ((a >= #58)) $b2a5;		//
$b276:
		if (a >= #46) $b2a6;		//fail:マドラのたてごと
		else $b2a5;
	}
$b27c:
	if (a >= #4f) {				//きのや
		if ((a = $1d) == 0) $b2a5;
		if (a >= #4f) $b2a6;		//きのや
		if (a >= #4a) $b2a5;		//ゆみ
		else sec; $b2a6;
	}
$b28f:
	if (a >= #4a) {				//ゆみ
		if ((a = $1d) == 0) $b2a5;
		else sec; $b2a6;
	}
$b29a:
	if (a >= #46) {				//マドラのたてごと
		if ((a = $1d) == 0) $b2a5;
		else sec; $b2a6;
	}
$b2a5:	clc;
$b2a6:	return;	
}
```



