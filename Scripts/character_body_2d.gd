extends CharacterBody2D

var grid: AStarGrid2D
var current_cell: Vector2i
@export var target_cell: Vector2i = Vector2i(0, 0)
var move_pts: Array
var cur_pt: int
var moving: bool = false
var end_pos: Vector2 = Vector2(0, 0)
@export var speed: float = 1

func _ready() -> void:
	Global.cat = self

func _physics_process(delta: float) -> void:
	
	#handle gravity
	if !is_on_floor():
		velocity.y += get_gravity().y * delta

	if !moving:
		start_move()

func setup(grid: AStarGrid2D):
	self.grid = grid
	current_cell = pos_to_cell(global_position)
	
func pos_to_cell(pos: Vector2):
	return pos / grid.cell_size

func path_to_end():
	if moving:
		return
	var target = Vector2i(pos_to_cell(target_cell))
	#if target != target_cell:
	move_pts = grid.get_point_path(current_cell, target)
	move_pts = (move_pts as Array).map(func (p): return p + grid.cell_size / 2.0)
	target_cell = target

func start_move():
	if move_pts.is_empty(): return
	cur_pt = 0
	moving = true
