
# $35:ba41 battle.process_poison
> 敵味方全員の毒状態を処理し、HP・ステータスの更新と表示を行う

### args:

+	in,out BattleCharacter $7575[12]: characters

### callers:

+	`$34:8074 battle.main_loop`

### local variables:

+	u8 $24: character index
+	BattleCharacter* $28: target
+	u8 $64: number of available damage values
+	u16 $7400[12]: damages over poison
+	u8 $78d5: command_chain_id. 0x05 == [$09,$0C,$0A,$04,$FF] where
	- 09: show info message
	- 0c: show damage
	- 0a: await input (of A button) or timeout
	- 04: close info message window
	- FF: end of chain
+	u8 $78da: battle messages queue. 0x41 == "どくのダメージ!" (TBC)
+	u16 $7e4f[12]: damage values to be presented
+	u8 $7e98: actor bits. 0x80 == actor is enemy
+	u8 $7e99: effect target bits. 0x80 == target is enemy
+	u8 $7e9a: effect_target_side. 0x40 == target is enemy side
+	u8 $7ec2: scene_id. where
	- 0x16: mapped to effect_handler 0F == show damage effect
	- 0x17: mapped to effect_handler 0E == show dying effect
+	u8 $7ec4[8]: character status (only for enemies)

### notes:
there are 2 bugs found to be caused by this function.
1.	in the situations when right after 'proliferation' has occurred,
	the screen effect for that is incorrectly played again after damages over poison shown.
2.	when 'landing' is executed with a poisoned character, it never gets 'landed'.

### (pseudo-)code:
```js
{
	a = 0xff;
	for (x = 0x1f;x >= 0;x--) {
		$7400.x = a;
	}
	$64 = 0;
	$24 = 8;
	$28,29 = 0x7575;
	for ($24;$24 != 0xc;$24++) {
		battle.apply_poison_damage();	//$badc();
		$28,29 += #40;
	}
$ba73:
	battle.cache_players_status();	//$9d06();
	$24 = 0;
	$28,29 = 0x7675;
	for ($24;$24 != 8;$24++) {
$ba82:
		battle.apply_poison_damage();	//$badc();
		x = $24;
		$7ec4.x = $28[y = 1];
		$28,29 += 0x40;
	}
$baa3:
	if ($64 != 0) { //beq $badb
		for (x = 0x1f;x >= 0;x--) {
			$7e4f.x = $7400.x;
		}
$bab2:
		$7e98 = $7e99 = 0x80;
		$7e9a = (a >> 1); //=#40
		$78d5 = 0x05;	//command_chain_id
		$78da = 0x41;	//message_id to queue
		$7ec2 = 0x17;	//scene_id: 0x17 => effect_handler: 0xF => play damage effect
		battle.present();	//8ff7
		$7ec2 = 0x16;	//scene_id: 0x16 => effect_handler: 0xE => play dying effect
		battle.play_effect();	//$8441()
		canPlayerPartyContinueFighting();	//$a458();
	}
$badb:
	return;
}
```






