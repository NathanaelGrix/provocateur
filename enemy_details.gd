class_name EnemyDetails
extends Resource

@export var idle_animation: String
@export var walk_animation : String
@export var dead_animation: String
@export var gunshot_sound: AudioStream
@export var attack_type: AttackType
@export_range(1,100) var attack_speed: int

#in future add different animations for bullets and maybe variation in attack style per enemey

enum AttackType{
	MELEE,
	RANGED
}
