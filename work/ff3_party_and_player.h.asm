;; ff3_party_and_player.h.asm
;;	provides structure definitions / address labels
;;	related to party or player data
;==================================================================================================
	.rsset 0
PLAYER_job				.rs 1
PLAYER_level			.rs 1
PLAYER_status			.rs 1
PLAYER_exp				.rs 3
PLAYER_name				.rs 6
PLAYER_hp				.rs 2
PLAYER_maxhp			.rs 2
PLAYER_job_level		.rs 1
PLAYER_job_exp			.rs 1

PLAYER_str_base			.rs 1	
PLAYER_agi_base			.rs 1
PLAYER_vit_base			.rs 1
PLAYER_int_base			.rs 1
PLAYER_men_base			.rs 1

PLAYER_str_effective	.rs 1	
PLAYER_agi_effective	.rs 1
PLAYER_vit_effective	.rs 1
PLAYER_int_effective	.rs 1
PLAYER_men_effective	.rs 1

PLAYER_attribute_weak	.rs 1

PLAYER_magical_times	.rs 1
PLAYER_magical_evade	.rs 1
PLAYER_magical_def		.rs 1

PLAYER_righthand_attr	.rs 1
PLAYER_righthand_times	.rs 1
PLAYER_righthand_hit	.rs 1
PLAYER_righthand_atk	.rs 1
PLAYER_righthand_enchant	.rs 1

PLAYER_lefthand_attr	.rs 1
PLAYER_lefthand_times	.rs 1
PLAYER_lefthand_hit		.rs 1
PLAYER_lefthand_atk		.rs 1
PLAYER_lefthand_enchant	.rs 1

PLAYER_attribute_resist	.rs 1

PLAYER_physical_times	.rs 1
PLAYER_physical_evade	.rs 1
PLAYER_physical_def		.rs 1

PLAYER_status_resist	.rs 1

PLAYER_mp_lv1			.rs 1
PLAYER_maxmp_lv1		.rs 1
;;}

;------------------------------------------------------------------------------
;; party.
party.world_id = $6007	;tbd. $3b:a12b
party.ally_npc = $600b	;
party.float_land_X = $600c;	tbd. $3e:c4fc
party.float_land_Y = $600d;	tbd. $3e:c4fc
party.leader_offset = $600e	;tbd. see also $3e:e917.
party.message_speed = $6010	;tbd.
;$6011 ;$3e:ddc6
party.capacity = $601b
party.gil = $601c	;24bit
party.event_flags = $6020	; 0x20 bytes (256 flags, including job flags) tbd. $3c:9344
party.job_flags = $6021	;lower 5bits represents each crystal event
party.treasure_flags = $6040
party.object_flags = $6080	;tbd. $3b:b34e, $3b:b51a

party.backpack.item_id = $60c0
party.backpack.item_count = $60e0

;------------------------------------------------------------------------------
player.base_params		= $6100	;0x40 bytes per character

player.job				= $6100
player.level			= $6101
player.status			= $6102
player.exp				= $6103
player.name				= $6106
player.hp				= $610c
player.maxhp			= $610e
player.job_level		= $6110
player.job_exp			= $6111

player.str_base			= $6112
player.agi_base			= $6113
player.vit_base			= $6114
player.int_base			= $6115
player.men_base			= $6116

player.attr_weak		= $6117

player.str_effective	= $6118
player.agi_effective	= $6119
player.vit_effective	= $611a
player.int_effective	= $611b
player.men_effective	= $611c

player.magical_times	= $611d
player.magical_evade	= $611e
player.magical_def		= $611f

player.righthand_attr	= $6120
player.righthand_times	= $6121
player.righthand_hit	= $6122
player.righthand_atk	= $6123
player.righthand_enchant= $6124

player.lefthand_attr	= $6125
player.lefthand_times	= $6126
player.lefthand_hit		= $6127
player.lefthand_atk		= $6128
player.lefthand_enchant	= $6129

player.attribute_resist	= $612a

player.physical_times	= $612b
player.physical_evade	= $612c
player.physical_def		= $612d

player.status_resist	= $612e

player.unknown_2f		= $612f

player.mp_lv1			= $6130
player.maxmp_lv1		= $6131
;------------------------------------------------------------------------------
player.equips			= $6200
;------------------------------------------------------------------------------
party.item_amount_in_stomach = $6300	;index = item_id.
;==================================================================================================
;; deprecated
backpackItems		= $60c0
playerBaseParams	= $6100
playerEquips		= $6200
