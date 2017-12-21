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
    -   37, 38, 39: サウンド・オーディオ データ
    -   39: 経験値テーブル

## 領域ごとの詳細
※ROMアドレスはヘッダーを含みません。

[start,end)  |usage | description
-------------|------|----------------------------------------------------------
000000-000400|data  | `ChipComposition [4]`, `ChipComopistion { u8 左上のタイル、右上、左下、右下 }`
000400-000500|data  | `ChipToPalette [4][64]`
000500-000800|data  | `ChipEvents [3][256]` index = world_id, `ChipEvents { u8 unknown, u8 event_param }`
000800-000900|data  | chip_id => warp_id mappings `u8 [2][64]`
000900-0009c0|data  | 装備フラグ 3x64
0009c0-000a00|?     |
000a00-000c00|data  | warp_id => floor_id mappings `u8 [2][256]`
000c00-000e00|data  | warp_id => tile_set_id mappings. `u8 [2][256]`
000e00-001100|data  | pointers (offset from 006000) of tile sets `u16 [0x30][0x8]` index: tile_set_id,  
001100-001400|data  | palette definition. `u8 colors[3][256]`
001400-001500|data  | object_id => sprite_pattern_id mappings `u8 [256]`
001500-002380|?     |
002380-00xxxx|data  | size TBC `ChipDef $01:a380[?][4][128]`
003100-003500|data  | `ChipToPalette $01:b100 [8][128]` @see $3a:9267 floor::init
003500-003c00|data  | size TBC `ChipAttributes $01:b500 [8][128] : chipAttributeTable { attributes, event }` index: higher 3bits of warpParam.initX
003c00-003e00|data  | treasure_id => item_id mappings. `u8 item_id[2][256]`
003e00-004000|?     |
004000-006000|data  | `WarpParam [2][256]` aka "floor_def", 16 byte/entry, index: warp_id
006000-00CC00|bitmap| map chips
00cc00-00d000|?     | seems like data, 8-byte structure
00d000-00d800|data  | pointers (offset from 0d000) of world-map data row `u16 [4][256]`
00d800-012000|data  | world map data @see `$3e:ccbb field::getMapDataPointers`
012000-014000|data  | audio stream (music id:3b...)
014000-020000|bitmap| sprites
020000-020200|data  | pointers of treasure lists. `u16 [256]`, index: treasure_list_id (warpparam+0e).
020200-020400|data  | pointers of event lists. `u16 [256]`, index: event_list_id (warpparam+0f).
020400-020a00|?     | data?
020a00-020e00|?     | seems like code
020E00-021640|bitmap| ending picture/font
021640-021d80|?     | data?
021b80-021c80|data  | `$10:9b80 u8 dropItemTable[8][32] = {}` index: mobparam[0xF] &1F
021c80-021d80|data  | `$10:9c80 u8 MonsterExpIndices[256] = {};` index: enemy_id
021d80-021e00|data  | `$10:9d80 u16 MonsterExp[64]` index: exp_id
021e00-022000|?     | data?
022000-022200|data  | pointers of floor-map (offset from 22000)
022200-030000|data  | floor map
030000-03e000|data  | pointers of string, strings
03e000-040000|?     | seems like a mix of code/data
040000-050000|bitmap| enemy
050000-054000|bitmap| player character sprites in battle
054000-058000|bitmap| effect animation sprites
058000-058200|data  | pointers of object placement lists (`u16 [256]`) index : object_list_id (warpparam.+04)
058200-058600|data  | pointers of event scripts (`u16 [2][256]`)
058600-058a00|data  | `$2c:8600 ObjectEvent event_definitions[256]` : 2-byte structure.
058a00-05c000|?     | seems like data, event scripts (variable length, up to 0x40 bytes)
05c000-05c400|data  | `$2e:8000 EncounterParam encounter_definitions[2][256]` : 2-byte struct.
05c400-05ca00|data  | `$2e:8400 EnemyParty party_definitions[256]` : 6-byte struct.
05ca00-05ca40|data  | `$2e:8a00 SpawnPattern spawn_patterns[64]` : 1-byte strucut.
05cb00-05cc00|data  | `$2e:8b00 u8 enemy_graphics_indices[256]`
05cc00-05d2f0|?     | known structure(s): `$2e:91a0 actionId cosumeableItemParam[0x30?]`
05d2f0-05d4f0|data  | mappigns of warp_id => encounter_table_id. `u8 [2][256]` @see: `$3d:bdb9 isEncounterOccured`
05d4f0-05f4f0|data  | `EncounterTable table[256]`: 8-byte/entry. (of each has 8 encounter_id's)
060000-061000|data  | `$30:8000 MonsterBaseParam[256]`: 16-byte struct.
061000-061200|data  | `$30:9000 MonsterBattleParam[170]`: 3-byte struct. the last 2 bytes is padding.
061200-061400|data  | `$30:9200 AttackPatterns[64]` : 8 bytes/entry. (of each has 8 action_id's)
061400-0618c0|data  | `$30:9400 EquipableItem itemData[0x98]`: 8bytes/entry.
0618c0-061a80|data  | `$30:98c0 MagicParam magicData[0x38]`: 8 bytes/entry.
061a80-061b80|data  | `$30:9a80 MagicParams specialAttack[0x20] `: 8 bytes/entry.
061b80-062000|data  | details TBC
061e58-062000|code  | battle-mode logics: calculations
062000-064000|code  | battle-mode logics: calculations
064000-066000|code  | battle-mode logics: presentation
066000-068000|code  | battle-mode logics: presentation
068000-06a000|code  | battle-mode logics: flow controllers
06a000-06c000|code  | battle-mode logics: flow controllers
06c000-070000|mixed | sound driver, audio stream (music id:0x00...0x18)
070000-072000|data  | audio stream (0x18...2a)
072000-0720b0|data  | audio stream (2b...3a), `$39:8000 JobBaseInfo jobParams[22]`: 8bytes/entry
0720b0-0721d6|?     |
0721d6-0732a2|data  | `$39:a1d6 LvUpParam lvupParams[98][22]`: 2bytes/entry => 0x10d8 bytes
0732a2-0732ae|?     |
0732ae-0733ae|data  | `$39:b2ae u8 DropCapacity[256] = {};`
0733b0-073c00|?     | seems like code, known structure(s): `$39:bb1a JobParam jobParams[22] //5bytes/entry`, `$39:bb88 u8 initialMp[8][9] //index=mp_type`
073c00-073e00|data  | warp_id => terrain_id mappings. `u8 [2][256]`.
073e00-074000|data  | `u8 encounter_bounds[2][256]` index: warp_id.
074180-074500|bitmap| "final fantasy iii"
074500-076000|code  | world-mode logics, floor-mode logics, menu-mode logics
076000-078000|code  | world-mode logics, floor-mode logics, menu-mode logics
078000-07a000|code  | world-mode logics, floor-mode logics, menu-mode logics
07a000-07c000|code  | world-mode logics, floor-mode logics, menu-mode logics
07c000-07e000|code  | world-mode logics, floor-mode logics, menu-mode logics
07e000-080000|code  | common logics, text driver, ppu driver, interrupt handlers, world-mode logics, floor-mode logics, menu-mode logics