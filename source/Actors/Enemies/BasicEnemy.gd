class_name BasicEnemy
extends PathFollow2D

signal movement_started
signal movement_finished

export var move_delay := 0.5
export var speed := 64.0 setget set_speed
export var move_length := 1.0
export var gold_amount := 50

onready var _tween := $MovementTween
onready var _health := $Health
onready var _health_bar := $HealthBar
onready var _anim := $AnimationPlayer
onready var _sprite_anim := $Sprite/AnimationPlayer


func _ready() -> void:
	_health_bar.value = _health.amount
	_health_bar.max_value = _health.max_amount


func set_speed(new_speed: float) -> void:
	speed = new_speed
	if not is_inside_tree():
		yield(self, "ready")
	if _tween.is_active():
		_walk_path()


func move() -> void:
	yield(get_tree().create_timer(move_delay), "timeout")
	emit_signal("movement_started")
	_walk_path()


func apply_damage(damage: int) -> void:
	_health.amount -= damage


func die() -> void:
	Player.current_gold += gold_amount
	_tween.stop_all()
	_anim.play("die")


func disappear() -> void:
	_tween.stop_all()
	_anim.play("die")


func _walk_path() -> void:
	if _tween.is_active():
		_tween.stop(self, "unit_offset")
	
	var duration := move_length / speed
	# Sets the duration relative to where the Enemy is on the walk path
	duration -= duration * unit_offset
	
	_tween.interpolate_property(self, "unit_offset", unit_offset, 1.0, duration)
	_tween.start()


func _on_HurtBoxArea2D_hit_landed(hit: Hit) -> void:
	apply_damage(hit.damage)
	# Hits are added as children in order to process their Modifiers 
	add_child(hit)
	for modifier in hit.modifiers.get_children():
		modifier.target = self
	_walk_path()


func _on_MovementTween_tween_completed(object: Object, key: NodePath) -> void:
	if unit_offset >= 1.0:
		emit_signal("movement_finished")
		disappear()


func _on_Health_changed(current_amount: int) -> void:
	if not is_inside_tree():
		yield(self, "ready")
	_health_bar.value = current_amount


func _on_Health_depleted() -> void:
	die()


func _on_Health_max_changed(new_max: int) -> void:
	if not is_inside_tree():
		yield(self, "ready")
	_health_bar.max_value = new_max
