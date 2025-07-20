class_name Block extends Node2D

@export var animate_movement: = true

@onready var sprite: Sprite2D = $Visuals/Sprite2D
@onready var visuals: Node2D = $Visuals
@onready var label: Label = $Visuals/Sprite2D/Label

var COLORS: Array[Color] = [
	Color.GOLD, #YELLOW
	Color.HOT_PINK, #PINK
	Color.TOMATO, #RED
	Color.CHARTREUSE, #GREEN
	Color.DARK_CYAN, #BLUE
	Color.BLUE_VIOLET, #PURPLE
]

var NUMS: Array[String] = [
	"⚀",
	"⚁",
	"⚂",
	"⚃",
	"⚄",
	"⚅"
]

var _grid_pos := Vector2.ZERO
var grid_pos: Vector2:
	set(val):
		_grid_pos = val
		if not animate_movement:
			return
		var move_tween := get_tree().create_tween()
		var next_pos: Vector2 = val * 64
		move_tween.tween_property(self, "global_position", next_pos, 0.2).set_ease(Tween.EASE_IN_OUT)
	get:
		return _grid_pos

var _val := 1
var value: int :
	set(val):
		_val =  val
		sprite.material.set("shader_parameter/first_color", COLORS[_val])
		sprite.material.set("shader_parameter/second_color", COLORS[_val].darkened(0.3))
		label.text = NUMS[val]
	get:
		return _val

func _ready() -> void:
	visuals.scale = Vector2.ZERO
	var spawn_tween = get_tree().create_tween()
	spawn_tween.set_trans(Tween.TRANS_ELASTIC)
	spawn_tween.tween_property(visuals, "scale", Vector2.ONE, 0.5)
	value = randi_range(0, 5)
