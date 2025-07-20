class_name SpawnIndicator extends Node2D

@onready var state_machine = $AnimationTree["parameters/playback"]

var _grid_pos: Vector2 = Vector2.ZERO
var grid_pos: Vector2:
	set(val):
		_grid_pos = val
		state_machine.travel("indicator_move")
	get:
		return _grid_pos

func _handle_indicator_moved():
		self.visible = true
		self.position = grid_pos * 64
