# FF3 (FC原版)のROM領域の用途

## 各バンクのおおまかな用途

-   コード
    -   1e, 1f: 詳細不明(おそらくイベント関連)
    -   2e, 2f, 32, 33: 戦闘時の画面処理(PPU)関連
    -   30, 31, 34, 35: 戦闘関連のゲームロジック
    -   36, 37: サウンドドライバー
    -   3a, 3b, 3c, 3d: メニュー処理、フロアのゲームロジック
    -   3e, 3f: 汎用ロジック、非戦闘時のウインドウ関連、テキスト処理ロジックなど

-   データ
    -   00 ... 06: マップ、マップチップのビットマップ、スプライトの構成データ
    -   06: フィールドマップ 構成データ
    -   0a ... 0f: スプライト・マップ ビットマップ
    -   0e, 0f: スプライト(人) ビットマップ
    -   10: 敵キャラパラメータ、イベント構成データ
    -   11: フロアマップ 構成データ
    -   18 ... 1e: テキスト
    -   20 ... 29: 敵キャラ ビットマップ
    -   2a, 2b: エフェクト ビットマップ・構成データ
    -   2c, 2d: NPC配置データ
    -   39: 経験値テーブル

## 領域ごとの詳細
※ROMアドレスはヘッダーを含みません。

[start,end)  |usage | description
-------------|------|----------------------------------------------------------
000000-000300|?     |seems like code
000300-000900|?     |seems like data (8-byte structures)
000900-0009c0|data  | 装備フラグ 3x64
000c00-000e00|data  | warp(floor-def) => tile sets
000e00-001000|data  | tile sets
006000-00CC00|bitmap| map chips
00cc00-00d000|?     |seems like data, 8-byte structure
00d000-00d400|data  | pointers of world-map data row
00d400-014000|data  | world map  ? seems like data, 8-byte structure
014000-020000|bitmap| sprites
020000-020a00|data  | pointers of map rows
020a00-020e00|?     | seems like code
020E00-021640|bitmap| ending picture/font
021640-021d80|?     | data?
021b80-021c80|data  | `$10:9b80 u8 dropItemTable[8][32] = {}` index: mobparam[0xF] &1F
021c80-021d80|data  | `$10:9c80 u8 MonsterExpIndices[256] = {};` index: enemy_id
021d80-021e00|data  | `$10:9d80 u16 MonsterExp[64]` index: exp_id
021640-030000|data  | floor map
030000-03e000|data  | pointers of string, strings
03e000-040000|?     | seems like a mix of code/data
040000-050000|bitmap| enemy
050000-054000|bitmap| player character sprites in battle
054000-058000|bitmap| effect animation sprites
058000-058200|?     | seems like data
058200-058600|data  | pointers to event script (`u16 [2][256]`)
058600-058a00|data  | `$2c:8600 ObjectEvent event_definitions[256]` : 2-byte structure.
058a00-060000|?     | seems like data, event scripts (variable length, up to 0x40 bytes)
05c000-05c400|data  | `$2e:8000 EncounterParam encounter_definitions[2][256]` : 2-byte struct.
05c400-05ca00|data  | `$2e:8400 EnemyParty party_definitions[256]` : 6-byte struct.
05ca00-05ca40|data  | `$2e:8a00 SpawnPattern spawn_patterns[64]` : 1-byte strucut.
05cb00-05cc00|data  | `$2e:8b00 u8 enemy_graphics_indices[256]`
05cc00-060000|?     | known structure(s): `$2e:91a0 actionId cosumeableItemParam[0x30?]`
060000-061000|data  | `$30:8000 MonsterBaseParam[256]`: 16-byte struct.
061000-061200|data  | `$30:9000 MonsterBattleParam[170]`: 3-byte struct. the last 2 bytes is padding.
061200-061xxx|data  | `$30:9200 AttackPatterns[8][?]` : 8 bytes/entry.
061400-0618c0|data  | `$30:9400 EquipableItem itemData[0x98]`: 8bytes/entry.
0618c0-061a80|data  | `$30:98c0 MagicParam magicData[0x38]`: 8 bytes/entry.
061a80-061b80|data  | `$30:9a80 MagicParams specialAttack[0x20] `: 8 bytes/entry.
061b80-062000|data  | details TBC
062000-06c000|code  | battle-mode logics
06c000-070000|code  | sound driver
070000-072000|?     | seems like code
072000-0720b0|data  | `$39:8000 JobBaseInfo jobParams[22]`: 8bytes/entry
0720b0-0721d6|?     |
0721d6-0732a2|data  | `$39:a1d6 LvUpParam lvupParams[98][22]`: 2bytes/entry => 0x10d8 bytes
0732a2-0732ae|?     |
0732ae-0733ae|data  | `$39:b2ae u8 DropCapacity[256] = {};`
0733b0-074180|?     | seems like code, known structure(s): `$39:bb1a JobParam jobParams[22] //5bytes/entry`, `$39:bb88 u8 initialMp[8][9] //index=mp_type`
074180-074500|bitmap| "final fantasy iii"
074500-07ffff|code  | world-mode logics, floor-mode logics, menu-mode logics, text driver, common logics