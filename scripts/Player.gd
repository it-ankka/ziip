extends Node2D

@onready var block: Block = $Block
@onready var sprite: Sprite2D = $Block/Visuals/Sprite2D
@onready var dir_indicator: Node2D = $PlayerClipMask/PlayerDirectionIndicator
@onready var trail: CPUParticles2D = $CPUParticles2D
@onready var game: Game = self.get_tree().root.get_node("/root/Game")

@export var blockDestructionParticles: PackedScene = preload("res://scenes/destruction_particles.tscn")

var value: int :
	set(val):
		block.value = val
		trail.color = block.COLORS[block.value]
	get:
		return block.value

var can_move = true
var cur_dir = Vector2.UP
var grid_pos: Vector2:
	set(val):
		block.grid_pos = val
	get:
		return block.grid_pos
var input_buffer : Array[Vector2] = []

func destroy_block(b: Block):
	var destructionParticles: CPUParticles2D = blockDestructionParticles.instantiate()
	destructionParticles.finished.connect(func(): destructionParticles.queue_free())
	get_tree().current_scene.add_child(destructionParticles)
	destructionParticles.modulate = b.COLORS[b.value]
	destructionParticles.global_position = b.global_position + Vector2(32, 32)
	destructionParticles.emitting = true
	b.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trail.color = block.COLORS[block.value]

func _input(event: InputEvent) -> void:
	if event.is_action("ui_accept") and can_move:
		var lane = game.get_lane(grid_pos, cur_dir)
		if not lane:
			return

		can_move = false

		# Move to game script

		var tween := get_tree().create_tween()
		tween.finished.connect(func(): can_move = true)
		var blocks: Array = game.blocks_by_lane[lane] if game.blocks_by_lane.has(lane) else []
		if blocks.is_empty():
			tween.tween_property(self, "global_position", lane * 64, 0.1)
			tween.tween_property(self, "global_position", grid_pos * 64, 0.1)
			return

		var destroyed := []
		for b in blocks:
			print("block: %d b: %d" % [block.value, b.value])
			if block.value != b.value:
				break
			destroyed.append(b)

		for b in destroyed:
			blocks.erase(b)

		print("destroyed %d" % destroyed.size())

		var anim_pos = blocks.front().global_position if not blocks.is_empty() else lane * 64
		tween.tween_property(self, "global_position", anim_pos, 0.1)
		var switch_values = func():
			for i in range(len(destroyed)):
				var b = destroyed[i]
				var t = get_tree().create_timer(0.05 * i)
				t.timeout.connect(func(): destroy_block(b))
			var temp_val = block.value
			if not blocks.is_empty():
				value = blocks.front().value
				blocks.front().value = temp_val
		tween.tween_callback(switch_values)
		tween.tween_property(self, "global_position", grid_pos * 64, 0.1)
		return

	var input_dir = Vector2.ZERO
	if event.is_action("ui_left"):
		input_dir = Vector2.LEFT
	elif event.is_action("ui_right"):
		input_dir = Vector2.RIGHT
	elif event.is_action("ui_up"):
		input_dir = Vector2.UP
	elif event.is_action("ui_down"):
		input_dir = Vector2.DOWN
	if input_dir:
		if event.is_pressed() and not input_buffer.has(input_dir):
			input_buffer.append(input_dir)
		elif event.is_released():
			input_buffer.erase(input_dir)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir = input_buffer.back() if not input_buffer.is_empty() else Vector2.ZERO
	var new_grid_pos := Vector2i(grid_pos.x + dir.x, grid_pos.y + dir.y);
	var is_inside_player_area := new_grid_pos.x > -3 and new_grid_pos.x < 2 and new_grid_pos.y > -3 and new_grid_pos.y < 2
	if dir and can_move:
		cur_dir = dir
		dir_indicator.rotation = -cur_dir.angle_to(Vector2.UP)
		if is_inside_player_area:
			can_move = false
			grid_pos = new_grid_pos
			var pos: Vector2i = grid_pos * 64
			var move_tween = get_tree().create_tween()
			move_tween.tween_property(self, "global_position", Vector2(pos.x, pos.y), 0.1).set_ease(Tween.EASE_IN_OUT)
			move_tween.finished.connect(func(): can_move = true)

	dir_indicator.global_position = self.global_position + Vector2(32,32)
