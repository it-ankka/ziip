class_name Game extends Node2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var level_label: Label = $UI/LevelLabel
@onready var score_label: Label = $UI/ScoreLabel

@export var block_scene: PackedScene

@export var initial_blocks: int = 1

const W = 18
const H = 14
const MIN_X = -9
const MIN_Y = -7
const MAX_X = 8
const MAX_Y = 6
const LANE_MIN = -2
const LANE_MAX = 1

var blocks_by_lane: Dictionary[Vector2, Array] = {}
var next_spawn: Vector2 = _get_random_spawn()
var _score: int = 0
var _level: int = 1

func _ready() -> void:
	spawn_timer.timeout.connect(_spawn)
	for i in range(initial_blocks):
		_spawn()

	spawn_timer.start()

func _input(event: InputEvent) -> void:
	if event.is_action("reload"):
		get_tree().reload_current_scene()

func _get_random_spawn() -> Vector2:
	var lane = randi_range(LANE_MIN, LANE_MAX)
	if randf() > 0.5:
		return Vector2(MIN_X if randf() < 0.5 else MAX_X, lane)
	return Vector2(lane, MIN_Y if randf() < 0.5 else MAX_Y)

func _get_side(pos: Vector2) -> Vector2:
	if pos.x < LANE_MIN: return Vector2.LEFT
	elif pos.x > LANE_MAX: return Vector2.RIGHT
	elif pos.y < LANE_MIN: return Vector2.UP
	elif pos.y > LANE_MAX: return Vector2.DOWN
	else: return Vector2.ZERO

func get_lane(pos: Vector2, dir: Vector2) -> Vector2:
	if dir == Vector2.LEFT: return Vector2(MIN_X, pos.y)
	elif dir == Vector2.RIGHT: return Vector2(MAX_X, pos.y)
	elif dir == Vector2.UP: return Vector2(pos.x, MIN_Y)
	elif dir == Vector2.DOWN: return Vector2(pos.x, MAX_Y)
	return Vector2.ZERO

func _spawn():
	var block: Node2D = block_scene.instantiate()
	if not is_inside_tree():
		return
	get_tree().current_scene.add_child(block)

	block.grid_pos = next_spawn
	if not blocks_by_lane.has(next_spawn):
		blocks_by_lane[next_spawn] = [block]
	else:
		var move_dir = _get_side(next_spawn) * -1
		for lane_block: Block in blocks_by_lane[next_spawn]:
			lane_block.grid_pos += move_dir
		blocks_by_lane[next_spawn].append(block)

	for lane in blocks_by_lane.values():
		for b: Block in lane:
			if b.grid_pos.x >= LANE_MIN and b.grid_pos.x <= LANE_MAX and b.grid_pos.y >= LANE_MIN and b.grid_pos.y <= LANE_MAX:
				get_tree().reload_current_scene()

	block.global_position = next_spawn * 64

	# Get next spawn
	var new_spawn = next_spawn
	while(new_spawn == next_spawn):
		new_spawn = _get_random_spawn()
	next_spawn = new_spawn
	$SpawnIndicator.grid_pos = next_spawn

func _update_game_state():
	pass
