
# $2f:a02a loadEnemyGroups

### args:

#### in
+	$7ced,7cee : encounter_id?
+	$2e:8000 : encounter_params { enemy_party_id, spawn_param_id }[512]
	-	index: encounter_id
+  $2e:8400 : enemy_party_table { palette_ [2], enemy_id[4] }[256]
	-	index: enemy_party_id
+  $2e:8a00 : spawn_param_table { {u4 min,max}[4] }[64]
	-	index: spawn_param_id

#### out
+	encounter_params            $7d67 : loaded_encounter_params
+	enemy_party_table           $7d69 : loaded_enemy_party
+	u8[4]                       $7d6f : number of the enemy spawned
+	enemy_graphics_params[4]    $7d73 : loaded_enemy_graphics_params

### code:
```js
{
	$7e,7f = $7ced,$7cee
	$7e,7f <<= 1;
	$7e,7f += #8000;

	$7d67 = $7e[y = 0];
	$7d68 = $7e[++y];

	mul8x8_reg(a = $7d67,x = 6);	//$f8ea();
	$7e,7f = (a,x) + #8400;
	//7e = pEnemyParty (8400-)
	for (y = 0;y != 6;y++) {
$a066:
		$7d69.y = $7e[y];
	}
$a070:
	for (x = 0,y = 0; x != 4; x++, y+= 2) {
$a074:
		a = $7d6b.y;
		load_enemy_graphics_params( enemy_id: a ); //$a0e7
		$7d73.y = $7e;    // graphics_id
		$7d74.y = $7f;    // 
	}
$a08b:
	$7e,7f = $7d68 & #003f;
	$7e,7f <<= 2;
	$7e,7f += #8a00;
	//7e = pEnemyNumberTable
$a0ab:
	for (y = 0;y != 4;y++) {
		$7d6f.y = $7e[y];
	}
$a0b7:
	for (x = 0;x != 4;x++) {
		$7d6f.x = randomizeEnemyCount(a = $7d6f.x);	//a0c8
	}
	return;
$a0c8:
}
```


