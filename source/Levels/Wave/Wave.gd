extends Node2D

signal started
signal finished

export var enemies_offset := Vector2(0, 64.0)


func _on_Enemy_tree_exited() -> void:
	if is_wave_finished():
		emit_signal("finished")


func _on_Enemy_movement_finished(enemy: BasicEnemy) -> void:
	enemy.queue_free()


func start() -> void:
	emit_signal("started")
	for enemy in get_children():
		if enemy.get_index() > 0:
			enemy.position -= enemies_offset
		enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
		enemy.connect("movement_finished", self, "_on_Enemy_movement_finished", [enemy])
		enemy.move()
		yield(enemy, "moved")


func is_wave_finished() -> bool:
	return get_child_count() < 1


func setup_enemy_movement_path(enemy: BasicEnemy,
		movement_path: PoolVector2Array) -> void:
	enemy.movement_path = movement_path
