extends TileMapLayer

var is_position_point: bool
var pos: Vector2
var a_star_graph: AStar2D = AStar2D.new()
var used_tiles: Array[Vector2i]
var point_info_list: Array[point_info]
var graph_point_inst

@export var show_debug_graph: bool = true
@export var cell_empty = -1
@export var max_tile_fall_scan_depth = 500
@export var graph_point: PackedScene
@export var jump_distance: float = 5
@export var jump_height: float = 4

class point_info:
	var pos
	var is_fall_tile: bool
	var is_left_edge: bool
	var is_right_edge: bool
	var is_left_wall: bool
	var is_right_wall: bool
	var point_id: float
	func _init(point_id, pos) -> void:
		self.point_id = point_id
		self.pos = pos	


func set_point_info(point_id, position):
	self.point_id = point_id
	self.position = position

func _ready() -> void:
	#graph_point_inst = graph_point.instantiate()
	used_tiles = get_used_cells()
	purge_non_obstacles()
	#display_used_tiles()
	build_graph()

func build_graph():
	add_graph_points()
	
func add_graph_points():
	for tile in used_tiles:
		add_left_edge_point(tile)
		add_right_edge_point(tile)
		add_left_wall_point(tile)
		add_right_wall_point(tile)

func add_left_edge_point(tile: Vector2i):
	if tile_above_exist(tile):
		return
	if get_cell_source_id(Vector2i(tile.x - 1, tile.y)) == -1:
		var tile_above = Vector2i(tile.x, tile.y - 1)
		var existing_point_id = tile_already_exist_in_graph(tile_above)
		if(existing_point_id == -1):
			var point_id = a_star_graph.get_available_point_id()
			var point_info = point_info.new(point_id, Vector2i(map_to_local(tile_above)))
			point_info.is_left_edge = true
			point_info_list.append(point_info)
			a_star_graph.add_point(point_id, Vector2i(map_to_local(tile_above)))
			add_visual_point(tile_above)
		else:
			point_info_list[point_info_list.find(existing_point_id)].is_left_edge = true
			add_visual_point(tile_above)
	
func add_right_edge_point(tile: Vector2i):
	if tile_above_exist(tile):
		return
	if get_cell_source_id(Vector2i(tile.x + 1, tile.y)) == -1:
		var tile_above = Vector2i(tile.x, tile.y - 1)
		var existing_point_id = tile_already_exist_in_graph(tile_above)
		if(existing_point_id == -1):
			var point_id = a_star_graph.get_available_point_id()
			var point_info = point_info.new(point_id, Vector2i(map_to_local(tile_above)))
			point_info.is_right_edge = true
			point_info_list.append(point_info)
			a_star_graph.add_point(point_id, Vector2i(map_to_local(tile_above)))
			add_visual_point(tile_above)
		else:
			point_info_list[point_info_list.find(existing_point_id)].is_right_edge = true
			add_visual_point(tile_above)
	
func add_left_wall_point(tile: Vector2i):
	if tile_above_exist(tile):
		return
	if get_cell_source_id(Vector2i(tile.x - 1, tile.y)) != -1:
		var tile_above = Vector2i(tile.x, tile.y - 1)
		var existing_point_id = tile_already_exist_in_graph(tile_above)
		if(existing_point_id == -1):
			var point_id = a_star_graph.get_available_point_id()
			var point_info = point_info.new(point_id, Vector2i(map_to_local(tile_above)))
			point_info.is_left_wall = true
			point_info_list.append(point_info)
			a_star_graph.add_point(point_id, Vector2i(map_to_local(tile_above)))
			add_visual_point(tile_above)
		else:
			point_info_list[point_info_list.find(existing_point_id)].is_left_wall = true
			add_visual_point(tile_above)
			
func add_right_wall_point(tile: Vector2i):
	if tile_above_exist(tile):
		return
	if get_cell_source_id(Vector2i(tile.x + 1, tile.y)) != -1:
		var tile_above = Vector2i(tile.x, tile.y - 1)
		var existing_point_id = tile_already_exist_in_graph(tile_above)
		if(existing_point_id == -1):
			var point_id = a_star_graph.get_available_point_id()
			var point_info = point_info.new(point_id, Vector2i(map_to_local(tile_above)))
			point_info.is_right_wall = true
			point_info_list.append(point_info)
			a_star_graph.add_point(point_id, Vector2i(map_to_local(tile_above)))
			add_visual_point(tile_above)
		else:
			point_info_list[point_info_list.find(existing_point_id)].is_right_wall = true
			add_visual_point(tile_above)
			
func tile_above_exist(tile: Vector2i) -> bool:
	if get_cell_source_id(Vector2i(tile.x, tile.y - 1)) == cell_empty:
		return false
	return true

func add_visual_point(tile_above):
	if !show_debug_graph:
		return
	var graph_point = graph_point.instantiate()
	graph_point.position = map_to_local(tile_above)
	add_child(graph_point)

func tile_already_exist_in_graph(tile: Vector2i):
	var local_pos = map_to_local(tile)
	if a_star_graph.get_point_count() > 0:
		var point_id = a_star_graph.get_closest_point(local_pos)
		if a_star_graph.get_point_position(point_id) == local_pos:
			return point_id
	return -1

func display_used_tiles():
	for tiles in used_tiles:
		print(tiles)

func purge_non_obstacles():
	for tile in used_tiles:
		var data = get_cell_tile_data(tile)
		if !data.get_custom_data("obstacle"):
			used_tiles.erase(tile)
			
func connect_points():
	for p1 in point_info_list:
		connect_horizontal_points(p1)
	
func _draw() -> void:
	if show_debug_graph:
		connect_points()
	
func connect_horizontal_points(p1: point_info):
	if p1.is_left_edge or p1.is_left_wall:
		var closest
		for p2 in point_info_list:
			if p1.point_id == p2.point_id:
				continue
			if (p2.is_right_edge or p2.is_right_wall) && p2.pos.y == p1.pos.y && p2.pos.x > p1.pos.x:
				if closest == null:
					closest = point_info.new(p2.point_id, p2.pos)
				if p2.pos.x < closest.pos.x:
					closest.pos = p2.pos
					closest.point_id = p2.point_id
		if closest != null:
			if !horizontal_connection_cannot_be_made(p1.pos, closest.pos):
				a_star_graph.connect_points(p1.point_id, closest.point_id)
				draw_debug_line(p1.pos, closest.pos, Color.RED)

func draw_debug_line(to: Vector2, from: Vector2, color: Color):
	if show_debug_graph:
		draw_line(to, from, color)

func horizontal_connection_cannot_be_made(p1: Vector2i, p2: Vector2i) -> bool:
	var start_scan: Vector2i = local_to_map(p1)
	var end_scan: Vector2i = local_to_map(p2)
	for i in range(start_scan.x, end_scan.x):
		if get_cell_source_id(Vector2i(i, start_scan.y)) != cell_empty or get_cell_source_id(Vector2i(i, start_scan.y + 1)) == cell_empty:
			return true
	return false

func connect_jump_points(p1: point_info):
	for p2 in point_info_list:
		connect_horizontal_platform_jumps(p1, p2)
		
func connect_horizontal_platform_jumps(p1: point_info, p2: point_info):
	if p1.point_id == p2.point_id:
		return
	if p2.pos.y == p1.pos.y && p1.is_right_edge && p2.is_left_edge:
		if p2.pos.x > p1.pos.x:
			var p2_map = local_to_map(p2.pos)
			var p1_map = local_to_map(p1.pos)
			if p2_map.distance_to(p1_map) < jump_distance + 1:
				a_star_graph.connect_points(p1.point_id, p2.point_id)
				draw_debug_line(p1.pos, p2.pos, Color.DEEP_PINK)
