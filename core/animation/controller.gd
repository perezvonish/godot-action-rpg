class_name AnimationController
extends Node2D

@export var animatedSprites: AnimatedSprite2D

func play_animation(animation_name: StringName) -> void:
	animatedSprites.play(animation_name)
