class_name EnemyDetails
extends Resource

@export var sprite: SpriteFrames
@export var attack_type: AttackType
@export_range(1,100) var attack_speed: int

enum AttackType{
	MELEE,
	RANGED
}
