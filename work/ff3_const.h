; ff3_const.h
;
; various constant value definitions
;--------------------------------------------------------------------------------
; original consts

;--------------------------------------------------------------------------------
;status flags
;
STATUS_LITE_MASK	= $01
; heavy
STATUS_POISON		= $02
STATUS_BLIND		= $04
STATUS_MINIMUM		= $08
STATUS_SEALED		= $10
STATUS_TOAD		= $20
STATUS_STONE		= $40
STATUS_DEAD		= $80
; lite
STATUS_JUMPING		= $01	; valid only in battle (cannot enchant)
STATUS_PETRIFY_MASK	= $06
STATUS_REMAIN_MASK	= $18
STATUS_CONFUSED		= $20
STATUS_SLEEPING		= $40
STATUS_PARALYZED	= $80

;--------------------------------------------------------------------------------
;BattleChar related
;
BP_OFFSET_STATUS_HEAVY		= $01
BP_OFFSET_STATUS_LITE		= $02
X_BP_OFFSET_PARAM			= $1e
X_BP_OFFSET_TYPE			= $1f
BP_OFFSET_ATTACK_MULTIPLIER = $27
BP_OFFSET_CRITICAL_RATE		= $28
BP_OFFSET_INDEX_AND_MODE	= $2c
BP_OFFSET_ACTION_ID		= $2e
BP_OFFSET_ACTION_TARGET	= $2f
BP_OFFSET_TARGET_FLAG		= $30
BP_OFFSET_SPECIAL_RATE		= $37

TARGET_ENEMY_PARTY	= $80
TARGET_MULTIPLE		= $40

;--------------------------------------------------------------------------------
; action ids
;

ACTION_NOTHING	= $00
ACTION_FIGHT	= $04
ACTION_ESCAPE	= $06


;--------------------------------------------------------------------------------
; job ids
;

JOB_THIEF	= $08

;--------------------------------------------------------------------------------
; chip ids
;

CHIPID_TREASURE_BOX = $7c
CHIPID_OPENED_TREASURE_BOX = $7d

;--------------------------------------------------------------------------------
; treasure

TREASURE_WITH_ENCOUNTER_BASE = $e0

;--------------------------------------------------------------------------------
; event flags

EVENT_FLAG_ENCOUNTER = $20

;--------------------------------------------------------------------------------
; extention to original

;EXSTATUS_OFFSET_PARAM	= $1e
;EXSTATUS_OFFSET_TYPE	= $1f

EFFECT_PROVOKE  = $19
EFFECT_ABYSS	= $1a

CMDX_ID_BEGIN		= $16
CMDX_PROVOKE		= $16
CMDX_DISORDERED_SHOT= $17
CMDX_ABYSS			= $18
CMDX_RAID			= $19
CMDX_ID_END			= $1a

BATTLE_PROCESS_EX_DISORDERED_SHOT = $06

PRESENT_SCENE_EX_BLOWONLY = $26
PRESENT_SCENE_EX_ABYSS = $27

BF_PICK_RANDOM_TARGET = $0a
BF_GET_RANDOM_SUCCEEDED_COUNT = $0b
BF_CALC_DAMAGE = $0c