class_name SkillData
extends Resource

enum SkillTag {
	MELEE,
	SPELL
}

@export var name: String
@export var description: String
@export var tags: Array[SkillTag]
